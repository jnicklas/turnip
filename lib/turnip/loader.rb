module Turnip
  module Loader
    def load(*a, &b)
      if a.first.end_with?('.feature')
        require 'spec_helper'
        content = File.read(a.first)
        Turnip.run(content)
      else
        super
      end
    end
  end
end
