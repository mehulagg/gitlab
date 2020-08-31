# frozen_string_literal: true

require 'rspec/core/formatters'

module QA
  module Support
    class JsonFormatter < RSpec::Core::Formatters::JsonFormatter
      RSpec::Core::Formatters.register self, :message, :dump_summary, :stop, :seed, :close

      def dump_profile(profile)
        # We don't currently use the profile info. This overrides the base
        # implementation so that it's not included.
      end

      def stop(notification)
        # Based on https://github.com/rspec/rspec-core/blob/main/lib/rspec/core/formatters/json_formatter.rb#L35
        # But modified to include full details of multiple exceptions
        @output_hash[:examples] = notification.examples.map do |example|
          format_example(example).tap do |hash|
            e = example.exception
            if e
              exceptions = e.respond_to?(:all_exceptions) ? e.all_exceptions : [e]
              hash[:exceptions] = exceptions.map do |exception|
                {
                  class: exception.class.name,
                  message: exception.message,
                  backtrace: exception.backtrace
                }
              end
            end
          end
        end
      end

      private

      def format_example(example)
        file_path, line_number = location_including_shared_examples(example.metadata)

        {
          id: example.id,
          description: example.description,
          full_description: example.full_description,
          status: example.execution_result.status.to_s,
          file_path: file_path,
          line_number: line_number.to_i,
          run_time: example.execution_result.run_time,
          pending_message: example.execution_result.pending_message,
          testcase: example.metadata[:testcase],
          quarantine: example.metadata[:quarantine],
          screenshot: example.metadata[:screenshot]
        }
      end

      def location_including_shared_examples(metadata)
        if metadata[:shared_group_inclusion_backtrace].empty?
          [metadata[:file_path], metadata[:line_number]]
        else
          # If there are nested shared examples, the outermost location is last in the array
          metadata[:shared_group_inclusion_backtrace].last.formatted_inclusion_location.split(':')
        end
      end
    end
  end
end
