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

  # The global step module
  module Steps
    extend Define
  end

  class << self
    attr_accessor :type, :step_dirs

    def load_steps
      return if @steps_loaded
      Turnip.step_dirs.each do |dir|
        Dir.glob(File.join(dir, '**', "*steps.rb")).each { |file| load file, true }
      end
      @steps_loaded = true
    end
  end
end

Turnip.type = :turnip
Turnip.step_dirs = ['spec']

self.extend Turnip::DSL

require "turnip/rspec"
