module Turnip
  module DocumentationFormatterExtensions
    def initialize(output)
      super

      @current_step = nil
      @remaining_scenario_steps = []
    end

    def example_started(notification)
      super if defined?(super)

      @remaining_scenario_steps = notification.example.metadata[:turnip_steps].dup
    end

    def step_started(notification)
      @current_step = notification.step
      @remaining_scenario_steps.shift
    end

    def step_passed(notification)
      output.puts step_passed_output(notification.step)
    end

    def example_passed(passed)
      return super unless turnip_example?(passed)

      flush_messages if respond_to? :flush_messages
      @example_running = false
    end

    def example_pending(pending)
      return super unless turnip_example?(pending)

      output.puts step_pending_output(@current_step,
                                      pending.example.execution_result.pending_message)
      output.puts remaining_step_names

      flush_messages if respond_to? :flush_messages
      @example_running = false
    end

    def example_failed(failure)
      return super unless turnip_example?(failure)

      failure.example.metadata[:failed_step] = @current_step
      output.puts step_failed_output(@current_step)
      output.puts remaining_step_names

      flush_messages if respond_to? :flush_messages
      @example_running = false
    end

    private

      def turnip_example?(notification)
        notification.example.metadata[:turnip]
      end

      def step_passed_output(step)
        ::RSpec::Core::Formatters::ConsoleCodes.wrap("#{current_indentation}#{step}",
                                                     :success)
      end

      def step_pending_output(step, message)
        ::RSpec::Core::Formatters::ConsoleCodes.wrap("#{current_indentation}#{step} " \
                                                     "(PENDING: #{message})",
                                                     :pending)
      end

      def step_failed_output(step)
        ::RSpec::Core::Formatters::ConsoleCodes.wrap("#{current_indentation}#{step} " \
                                                     "(FAILED - #{next_failure_index})",
                                                     :failure)
      end

      def remaining_step_names
        @remaining_scenario_steps.map do |step|
          ::RSpec::Core::Formatters::ConsoleCodes.wrap("#{current_indentation}#{step}",
                                                       :default)
        end
      end
  end
end

# Only extend documentation formatter if it's loaded
if defined?(RSpec::Core::Formatters::DocumentationFormatter)
  module Turnip::DocumentationFormatterExtensions
    RSpec::Core::Formatters.register self, :example_started, :step_started, :step_passed
  end

  class ::RSpec::Core::Formatters::DocumentationFormatter
    prepend Turnip::DocumentationFormatterExtensions
  end

  class RSpec::Core::Formatters::ExceptionPresenter
    def encoded_description(description)
      return if description.nil?

      if example.metadata[:turnip] && example.metadata[:failed_step]
        step = example.metadata[:failed_step].to_s
        error = ::RSpec::Core::Formatters::ConsoleCodes.wrap(step, :failure)
        description = description.gsub(step, error)
      end

      encoded_string(description)
    end
  end
end
