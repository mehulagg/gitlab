# frozen_string_literal: true

module EE
  module Gitlab
    module Ci
      module Pipeline
        module Quota
          class JobActivity < Ci::Limit
            include ::Gitlab::Utils::StrongMemoize
            include ActionView::Helpers::TextHelper

            def initialize(namespace, project)
              @namespace = namespace
              @project = project
            end

            def enabled?
              ci_active_jobs_limit > 0
            end

            def exceeded?
              return false unless enabled?

              excessive_jobs_count > 0
            end

            def message
              return unless exceeded?

              'Active jobs limit exceeded by ' \
                "#{pluralize(excessive_jobs_count, 'job')} in the past 24 hours!"
            end

            private

            def excessive_jobs_count
              @excessive ||= jobs_in_alive_pipelines_count - ci_active_jobs_limit
            end

            # rubocop: disable CodeReuse/ActiveRecord
            def jobs_in_alive_pipelines_count
              @project.all_pipelines.created_after(24.hours.ago).alive.joins(:builds).count
            end
            # rubocop: enable CodeReuse/ActiveRecord

            def ci_active_jobs_limit
              strong_memoize(:ci_active_jobs_limit) do
                @namespace.actual_limits.ci_active_jobs
              end
            end
          end
        end
      end
    end
  end
end
