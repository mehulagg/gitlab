# frozen_string_literal: true

module EE
  module Ci
    module RetryPipelineService
      extend ::Gitlab::Utils::Override
      include ::Gitlab::Utils::StrongMemoize

      private

      override :builds_relation
      def builds_relation(pipeline)
        super.eager_load_tags
      end

      override :can_be_retried?
      def can_be_retried?(build)
        super && !ci_minutes_exceeded?(build)
      end

      def ci_minutes_exceeded?(build)
        !runner_minutes.available?(build.build_matcher)
      end

      def runner_minutes
        strong_memoize(:runner_minutes) do
          ::Gitlab::Ci::Minutes::RunnersAvailability.new(project)
        end
      end
    end
  end
end
