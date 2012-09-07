module Turnip
  module Execute
    def step(description, *extra_args)
      extra_args.concat(description.extra_args) if description.respond_to?(:extra_args)

      matches = methods.map do |method|
        next unless method.to_s.start_with?("match: ")
        send(method.to_s, description.to_s)
      end.compact

      if matches.length == 0
        raise Turnip::Pending, description
      end

      if matches.length > 1
        msg = ['Ambiguous step definitions'].concat(matches.map(&:trace)).join("\r\n")
        raise Turnip::Ambiguous, msg
      end

      send(matches.first.method_name, *(matches.first.params + extra_args))
    end
  end
end
