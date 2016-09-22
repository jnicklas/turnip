require "gherkin/parser"
require "gherkin/token_scanner"

module Turnip
  class Builder
    module Tags
      def tags
        @raw[:tags].map { |tag| tag[:name].sub(/^@/, '') }
      end

      def tags_hash
        Hash[tags.map { |t| [t.to_sym, true] }]
      end

      def metadata_hash
        tags_hash
      end
    end

    module Name
      def name
        @raw[:name]
      end
    end

    module Line
      def line
        @raw[:location][:line]
      end
    end

    module Steps
      def steps
        @steps ||= @raw[:steps].map do |step|
          extra_args = []
          if (arg = step[:argument])
            if arg[:type] == :DataTable
              table = Turnip::Table.new(arg[:rows].map {|r| r[:cells].map {|c| c[:value]}})
              extra_args.push(table)
            else
              extra_args.push arg[:content]
            end
          end
          Step.new(step[:text], extra_args, step[:location][:line], step[:keyword])
        end
      end
    end

    class Feature
      include Tags
      include Name
      include Line

      attr_reader :scenarios, :backgrounds
      attr_accessor :feature_tag

      def initialize(raw)
        @raw = raw
        @scenarios = []
        @backgrounds = []
      end

      def metadata_hash
        super.merge(:type => Turnip.type, :turnip => true)
      end
    end

    class Background
      include Steps

      def initialize(raw)
        @raw = raw
      end
    end

    class Scenario
      include Tags
      include Name
      include Line
      include Steps

      attr_writer :steps

      def initialize(raw)
        @raw = raw
      end
    end

    class ScenarioOutline
      include Tags
      include Name
      include Steps

      def initialize(raw)
        @raw = raw
      end

      def to_scenarios
        return [] unless @raw[:examples]
        @raw[:examples].map { |example|
          headers = example[:tableHeader][:cells].map {|c| c[:value]}
          rows = example[:tableBody].map {|r| r[:cells].map {|c| c[:value]}}
          rows.map do |row|
            Scenario.new(@raw).tap do |scenario|
              scenario.steps = steps.map do |step|
                new_description = substitute(step.description, headers, row)
                new_extra_args = step.extra_args.map do |ea|
                  case ea
                  when String
                    substitute(ea, headers, row)
                  when Turnip::Table
                    Turnip::Table.new(ea.map {|t_row| t_row.map {|t_col| substitute(t_col, headers, row) } })
                  else
                    ea
                  end
                end
                Step.new(new_description, new_extra_args, step.line, step.keyword)
              end
            end
          end
        }.flatten
      end

      private

      def substitute(text, headers, row)
        text.gsub(/<([^>]*)>/) { |_| Hash[headers.zip(row)][$1] }
      end
    end

    class Step < Struct.new(:description, :extra_args, :line, :keyword)
      def to_s
        "#{keyword}#{description}"
      end
    end

    attr_reader :features

    class << self
      def build(feature_file)
        Turnip::Builder.new.tap do |builder|
          parser = Gherkin::Parser.new
          result = parser.parse(File.read(feature_file))
          builder.build(result)
        end
      end
    end

    def initialize
      @features = []
    end

    def build(attributes)
      return unless attributes[:feature]
      attr = attributes[:feature]
      feature = Feature.new(attr)
      attr[:children].each do |child|
        case child[:type]
        when :Background
          feature.backgrounds << Background.new(child)
        when :Scenario
          feature.scenarios << Scenario.new(child)
        else
          feature.scenarios.push(*ScenarioOutline.new(child).to_scenarios)
        end
      end
      @features << feature
    end
  end
end
