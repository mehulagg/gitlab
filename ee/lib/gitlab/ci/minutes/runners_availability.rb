# frozen_string_literal: true

module Gitlab
  module Ci
    module Minutes
      class RunnersAvailability
        include ::Gitlab::Utils::StrongMemoize

        def initialize(project)
          @project = project
        end

        def available?(build_matcher)
          return true unless project.shared_runners_enabled?

          !quota_exceeded?(build_matcher)
        end

        private

        attr_reader :project

        def quota_exceeded?(build_matcher)
          matches_instance_runners_and_quota_used_up?(build_matcher) &&
            !matches_private_runners?(build_matcher)
        end

        def matches_instance_runners_and_quota_used_up?(build_matcher)
          instance_runners.any? do |matcher|
            matcher.matches?(build_matcher) &&
              !matcher.matches_quota?(build_matcher)
          end
        end

        def matches_private_runners?(build_matcher)
          private_runners.any? { |matcher| matcher.matches?(build_matcher) }
        end

        def instance_runners
          strong_memoize(:instance_runners) do
            runner_matchers.select(&:instance_type?)
          end
        end

        def private_runners
          strong_memoize(:private_runners) do
            runner_matchers.reject(&:instance_type?)
          end
        end

        def runner_matchers
          strong_memoize(:runner_matchers) do
            project.all_runners.active.online.runner_matchers
          end
        end
      end
    end
  end
end
