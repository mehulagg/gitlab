# frozen_string_literal: true

module Gitlab
  module Ci
    module Runner
      class BuildMatching
        ATTRIBUTES = %i[
          runner_type
          public_projects_minutes_cost_factor
          private_projects_minutes_cost_factor
          run_untagged
          access_level
          tag_list
        ].freeze

        attr_reader(*ATTRIBUTES)

        def initialize(params)
          ATTRIBUTES.each do |attribute|
            instance_variable_set("@#{attribute}", params.fetch(attribute))
          end
        end

        def matches?(build)
          return false if access_level.to_sym == :ref_protected && !build.protected?

          accepting_tags?(build)
        end

        def matches_quota?(build)
          minutes_cost_factor(build.project.visibility_level) > 0 &&
            !build.project.ci_minutes_quota.minutes_used_up?
        end

        def instance_type?
          runner_type.to_sym == :instance_type
        end

        private

        def minutes_cost_factor(visibility_level)
          return 0.0 unless instance_type?

          case visibility_level
          when ::Gitlab::VisibilityLevel::PUBLIC
            public_projects_minutes_cost_factor
          when ::Gitlab::VisibilityLevel::PRIVATE, ::Gitlab::VisibilityLevel::INTERNAL
            private_projects_minutes_cost_factor
          else
            raise ArgumentError, 'Invalid visibility level'
          end
        end

        def accepting_tags?(build)
          (run_untagged || build.has_tags?) && (build.tag_list - tag_list).empty?
        end
      end
    end
  end
end
