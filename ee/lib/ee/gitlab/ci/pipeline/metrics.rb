# frozen_string_literal: true

module EE
  module Gitlab
    module Ci
      module Pipeline
        module Metrics
          def fail_quota_exceeding_builds_duration_histogram
            strong_memoize(:fail_quota_exceeding_builds_duration_histogram) do
              name = :gitlab_ci_fail_quota_exceeding_builds_duration_seconds
              comment = 'Duration for failing created jobs when CI minutes quota exceeded'
              labels = {}
              buckets = [0.01, 0.05, 0.1, 0.5, 1.0, 2.0, 5.0, 20.0, 50.0, 240.0]

              ::Gitlab::Metrics.histogram(name, comment, labels, buckets)
            end
          end

          def quota_exceeded_failed_builds_gauge
            strong_memoize(:ci_quota_exceeded_failed_builds_size) do
              ::Gitlab::Metrics.gauge(:gitlab_ci_quota_exceeded_failed_builds_size, 'Number of failed builds because of quota exhaustion')
            end
          end
        end
      end
    end
  end
end
