# frozen_string_literal: true

module EE
  module Ci
    module PipelineCreation
      module DropNotRunnableBuildsService
        extend ::Gitlab::Utils::Override

        private

        override :matching_instance_runners_available?
        def matching_instance_runners_available?(build_matcher)
          instance_runners
            .find { |matcher| matcher.matches?(build_matcher) && matcher.matches_quota?(build_matcher) }
            .present?
        end

        override :matching_failure_reason
        def matching_failure_reason(build_matcher)
          if matching_instance_runners?(build_matcher)
            :ci_quota_exceeded
          else
            :no_matching_runner
          end
        end
      end
    end
  end
end
