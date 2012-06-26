module Turnip
  module Execute
    def step(description, *extra_args)
      extra_args.concat(description.extra_args) if description.respond_to?(:extra_args)

      matches = methods.map do |method|
        next unless method.to_s.start_with?("match: ")
        send(method.to_s, description.to_s)
      end.compact
      raise Turnip::Pending, description if matches.length == 0
      if matches.length > 1
        msg = "Ambiguous step definitions:\r\n"
        matches.each_with_index do |match, index|
          # prepare an error message with some information on the ambiguous steps
          msg += "  #{index+1}. \"#{match.expression}\" (#{match.block.source_location.join(':')})\r\n"
        end
        raise Turnip::Ambiguous, msg
      end
      send(matches.first.expression, *(matches.first.params + extra_args))
    end
  end
end
