require "gherkin"

module Turnip
  class Builder
    module Tags
      def tags
        @raw.tags.map { |tag| tag.name.sub(/^@/, '') }
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
        @raw.name
      end
    end

    class Feature
      include Tags
      include Name

      attr_reader :scenarios, :backgrounds
      attr_accessor :feature_tag

      def initialize(raw)
        @raw = raw
        @scenarios = []
        @backgrounds = []
      end

      def line
        @raw.line
      end

      def metadata_hash
        super.merge(:type => Turnip.type, :turnip => true)
      end
    end

    class Background
      attr_reader :steps
      def initialize(raw)
        @raw = raw
        @steps = []
      end
    end

    class Scenario
      include Tags
      include Name

      attr_accessor :steps

      def initialize(raw)
        @raw = raw
        @steps = []
      end
    end

    class ScenarioOutline
      include Tags
      include Name

      attr_reader :steps

      def initialize(raw)
        @raw = raw
        @steps = []
      end

      def to_scenarios(examples)
        rows = examples.rows.map(&:cells)
        headers = rows.shift
        rows.map do |row|
          Scenario.new(@raw).tap do |scenario|
            scenario.steps = steps.map do |step|
              new_description = substitute(step.description, headers, row)
              new_extra_args = substitute_extra_args(step, headers, row)
              Step.new(new_description, new_extra_args, step.line)
            end
          end
        end
      end

      private

      def substitute(text, headers, row)
        text.gsub(/<([^>]*)>/) { |_| Hash[headers.zip(row)][$1] }
      end

      def substitute_extra_args(step, headers, row)
        return step.extra_args unless index = step.extra_args.find_index { |a| a.instance_of?(Turnip::Table) }
        extra_args = step.extra_args.dup
        table = extra_args[index].dup
        table.raw.each_index do |i|
          table.raw[i].each_index do |j|
            table.raw[i][j] = substitute(table.raw[i][j], headers, row)
          end
        end
        extra_args[index] = table
        extra_args
      end
    end

    class Step < Struct.new(:description, :extra_args, :line)
      # 1.9.2 support hack
      def split(*args)
        self.to_s.split(*args)
      end

      def to_s
        description
      end
    end

    attr_reader :features

    class << self
      def build(feature_file)
        Turnip::Builder.new.tap do |builder|
          parser = Gherkin::Parser::Parser.new(builder, true)
          parser.parse(File.read(feature_file), feature_file, 0)
        end
      end
    end

    def initialize
      @features = []
    end

    def background(background)
      @current_step_context = Background.new(background)
      @current_feature.backgrounds << @current_step_context
    end

    def feature(feature)
      @current_feature = Feature.new(feature)
      @features << @current_feature
    end

    def scenario(scenario)
      @current_step_context = Scenario.new(scenario)
      @current_feature.scenarios << @current_step_context
    end

    def scenario_outline(outline)
      @current_step_context = ScenarioOutline.new(outline)
    end

    def examples(examples)
      @current_feature.scenarios.push(*@current_step_context.to_scenarios(examples))
    end

    def step(step)
      extra_args = []
      if step.doc_string
        extra_args.push step.doc_string.value
      elsif step.rows
        extra_args.push Turnip::Table.new(step.rows.map { |row| row.cells(&:value) })
      end
      @current_step_context.steps << Step.new(step.name, extra_args, step.line)
    end

    def uri(*)
    end

    def eof
    end
  end
end
