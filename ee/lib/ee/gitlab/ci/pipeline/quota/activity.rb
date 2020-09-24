# frozen_string_literal: true

module EE
  module Gitlab
    module Ci
      module Pipeline
        module Quota
          class Activity < Ci::Limit
            include ::Gitlab::Utils::StrongMemoize
            include ActionView::Helpers::TextHelper

            def initialize(namespace, project)
              @namespace = namespace
              @project = project
            end

            def enabled?
              ci_active_pipelines_limit > 0
            end

            def exceeded?
              return false unless enabled?

              excessive_pipelines_count > 0
            end

            def message
              return unless exceeded?

              'Active pipelines limit exceeded by ' \
                "#{pluralize(excessive_pipelines_count, 'pipeline')}!"
            end

            private

            def excessive_pipelines_count
              @excessive ||= alive_pipelines_count - ci_active_pipelines_limit
            end

            def alive_pipelines_count
              @project.ci_pipelines.alive.count
            end

            def ci_active_pipelines_limit
              strong_memoize(:ci_active_pipelines_limit) do
                @namespace.actual_limits.ci_active_pipelines
              end
            end
          end
        end
      end
    end
  end
end
