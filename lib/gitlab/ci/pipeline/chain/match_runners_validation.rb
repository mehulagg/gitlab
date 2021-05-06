# frozen_string_literal: true

module Gitlab
  module Ci
    module Pipeline
      module Chain
        class MatchRunnersValidation < Chain::Base
          include Gitlab::Utils::StrongMemoize

          def perform!
            pipeline.stages.each do |stage|
              stage.statuses.each do |status|
                next unless status.is_a?(::Ci::Build)

                validate_build(status)
              end
            end
          end

          def break?
            false
          end

          private

          def validate_build(build)
            raise ArgumentError, 'to modify status of a build it cannot be persisted' if build.persisted?

            matching_private = private_runners.find { |matcher| matcher.matches?(build) }
            return if matching_private

            matching_instance = instance_runners.find { |matcher| matcher.matches?(build) && matcher.matches_quota?(build) }
            return if matching_instance

            matching_instance_but_no_quota = instance_runners.find { |matcher| matcher.matches?(build) }

            build.status = :failed
            build.failure_reason = matching_instance_but_no_quota ? :ci_quota_exceed : :ci_no_matching_runner
          end

          def instance_runners
            strong_memoize(:instance_runners) do
              build_matchers.select(&:instance_type?)
            end
          end

          def private_runners
            strong_memoize(:private_runners) do
              build_matchers.reject(&:instance_type?)
            end
          end

          def build_matchers
            strong_memoize(:build_matchers) do
              project.all_runners.build_matchers
            end
          end
        end
      end
    end
  end
end
