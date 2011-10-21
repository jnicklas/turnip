module Turnip
  class Feature
    attr_reader :scenarios, :backgrounds
    def initialize(raw)
      @raw = raw
      @scenarios = []
      @backgrounds = []
    end

    def name
      @raw.name
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
    attr_reader :name, :steps
    def initialize(raw)
      @raw = raw
      @steps = []
    end

    def name
      @raw.name
    end

    def tags
      @raw.tags.map { |tag| tag.name.sub(/^@/, '').to_sym }
    end

    def tags_hash
      Hash[tags.map { |t| [t, true] }]
    end

    def metadata_hash
      tags_hash
    end
  end

  class Step
    attr_reader :name
    def initialize(raw)
      @raw = raw
    end

    def name
      @raw.name
    end
  end

  class Builder
    attr_reader :features

    def initialize
      @features = []
    end

    def background(background)
      @current_step_context = Turnip::Background.new(background)
      @current_feature.backgrounds << @current_step_context
    end

    def feature(feature)
      @current_feature = Turnip::Feature.new(feature)
      @features << @current_feature
    end

    def scenario(scenario)
      @current_step_context = Turnip::Scenario.new(scenario)
      @current_feature.scenarios << @current_step_context
    end

    def step(step)
      @current_step = Turnip::Step.new(step)
      @current_step_context.steps << @current_step
    end

    def eof
    end
  end
end
