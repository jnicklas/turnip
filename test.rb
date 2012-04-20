require "turnip/step_definition"
require "turnip/placeholder"

step = Turnip::StepDefinition.new("this is a :test") { |test| "foo #{test}" }

module Step
  def self.define(object, text, &block)
    step = Turnip::StepDefinition.new(text, &block)
    object.send(:define_method, "step: #{step.expression}") { step }
    object.send(:define_method, "execute: #{step.expression}", &block)
  end

  def self.execute(object, text)
    match = find_step(object, text)
    object.send("execute: #{match.expression}", *match.params)
  end

  def self.find_step(object, text)
    object.methods.each do |method|
      method = method.to_s
      next unless method.start_with?("step:")
      match = object.send(method).match(text)
      return match if match
    end
  end
end

module DSL
  def step(text, &block)
    Step.define(self, text, &block)
  end
end

class Object
  def turnip_step(text)
    Step.execute(self, text)
  end
end

module Thing
  extend DSL

  step "foo (bar) :baz" do |baz|
    puts "in step #{baz}"
  end
end

module Schmoo
  include Thing
end

class Foo
  extend DSL
  include Schmoo

  step "foo (bar) :baz" do |baz|
    puts "inheritance"
    super(baz)
  end
end

foo = Foo.new
foo.turnip_step("foo bar baz")
foo.turnip_step('foo bar "Schmoo bar"')
foo.turnip_step("foo baz")
