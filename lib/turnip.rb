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
    attr_accessor :type, :step_dirs

    def load_steps(options = { :force => false })
      return if @steps_loaded && !options[:force]
      Turnip.step_dirs.each do |dir|
        Dir.glob(File.join(dir, '**', "*steps.rb")).each { |file| load file, true }
      end
      @steps_loaded = true
    end
  end
end

Turnip.type = :turnip
Turnip.step_dirs = ['spec']

Module.send(:include, Turnip::Define)

self.extend Turnip::DSL

require "turnip/rspec"
