# frozen_string_literal: true

module EE
  module Ci
    module PipelineCreation
      module DropNotRunnableBuildsService
        extend ::Gitlab::Utils::Override

        private

        override :matching_criteria
        def matching_criteria(runner_matcher, build_matcher)
          super && runner_matcher.matches_quota?(build_matcher)
        end

        override :matching_failure_reason
        def matching_failure_reason(build_matcher)
          if build_matcher.project.shared_runners_enabled_but_unavailable?
            :ci_quota_exceeded
          else
            :no_matching_runner
          end
        end
      end
    end
  end
end
