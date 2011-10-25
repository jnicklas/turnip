require "gherkin"
require "gherkin/formatter/tag_count_formatter"

require "turnip/version"
require "turnip/loader"
require "turnip/builder"
require "turnip/run"
require "turnip/step_definition"
require "turnip/placeholder"
require "turnip/dsl"
require "turnip/rspec"

module Turnip
  class << self
    attr_accessor :type
  end
end

Turnip.type = :turnip
