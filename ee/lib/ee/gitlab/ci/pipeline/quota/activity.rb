# frozen_string_literal: true

module EE
  module Gitlab
    module Ci
      module Pipeline
        module Quota
          class Activity < ::Gitlab::Ci::Limit
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

              alive_pipelines_count > ci_active_pipelines_limit
            end

            def message
              return unless exceeded?

              'Project has too many active pipelines! ' \
                "There are #{pluralize(alive_pipelines_count, 'active pipeline')}, "\
                "but the limit is #{ci_active_pipelines_limit}."
            end

            private

            def alive_pipelines_count
              strong_memoize(:alive_pipelines_limit) do
                @project.ci_pipelines.alive.count
              end
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
