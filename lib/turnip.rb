require "turnip/version"
require "turnip/dsl"
require "turnip/execute"
require "turnip/define"
require "turnip/builder"
require "turnip/step_definition"
require "turnip/placeholder"
require "turnip/table"

module Turnip
  class Pending < StandardError; end
  class Ambiguous < StandardError; end

  ##
  #
  # The global step module, adding steps here will make them available in all
  # your tests.
  #
  module Steps
  end

  class << self
    attr_accessor :type
  end
end

Turnip.type = :feature

Module.send(:include, Turnip::Define)

self.extend Turnip::DSL
