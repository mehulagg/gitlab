# frozen_string_literal: true

module Gitlab
  module Ci
    module Pipeline
      module Seed
        class Environment < Seed::Base
          attr_reader :job

          def initialize(job)
            @job = job
          end

          def to_resource
            job.project.environments.safe_find_or_create_by(
              name: expanded_environment_name,
              auto_stop_at: auto_stop_at
            )
          end

          private

          def auto_stop_at
            parsed_result = ChronicDuration.parse(job.environment_auto_stop_in)
            parsed_result.seconds.from_now
          rescue ChronicDuration::DurationParseError
            # Question: Should this error be reported somewhere?
            nil
          end

          def expanded_environment_name
            job.expanded_environment_name
          end
        end
      end
    end
  end
end
