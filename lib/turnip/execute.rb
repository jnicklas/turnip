module Turnip
  module Execute
    def step(description, extra_arg=nil)
      matches = methods.map do |method|
        next unless method.to_s.start_with?("match: ")
        send(method.to_s, description)
      end.compact
      raise Turnip::Pending, description if matches.length == 0
      raise Turnip::Ambiguous, description if matches.length > 1
      send("execute: #{matches.first.expression}", *(matches.first.params + [extra_arg].compact))
    end
  end
end
