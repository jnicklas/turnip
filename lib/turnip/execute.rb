module Turnip
  module Execute
    def step(step_or_description, *extra_args)
      if step_or_description.respond_to?(:extra_args)
        description = step_or_description.description
        extra_args.concat(step_or_description.extra_args)
      else
        description = step_or_description
      end

      matches = methods.map do |method|
        next unless method.to_s.start_with?("match: ")
        send(method.to_s, description)
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
