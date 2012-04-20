module Foo
  def foo
    puts "WorkS!"
  end
end

RSpec.configure do |config|
  config.include Foo, :bar => true
end

describe "test", :foo => true do
  it "does", :bar => true do
    foo
  end
end
