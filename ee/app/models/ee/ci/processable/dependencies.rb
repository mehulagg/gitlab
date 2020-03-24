# frozen_string_literal: true

module EE
  module Ci
    module Processable
      module Dependencies
        extend ActiveSupport::Concern
        extend ::Gitlab::Utils::Override

        # Dependencies can only be of Ci::Build type because only builds
        # can create artifacts
        DEPENDENCY = ::Ci::Build
        LIMIT = ::Gitlab::Ci::Config::Entry::Needs::NEEDS_CROSS_DEPENDENCIES_LIMIT

        override :cross_pipeline
        def cross_pipeline
          return [] unless processable.user_id
          return [] unless project.feature_available?(:cross_project_pipelines)

          cross_dependencies_relationship
            .preload(project: [:project_feature])
            .select { |job| user.can?(:read_build, job) }
        end

        private

        def cross_dependencies_relationship
          deps = Array(processable.options[:cross_dependencies])
          return DEPENDENCY.none unless deps.any?

          relationship_fragments = build_cross_dependencies_fragments(deps, DEPENDENCY.latest.success)
          return DEPENDENCY.none unless relationship_fragments.any?

          DEPENDENCY
            .from_union(relationship_fragments)
            .limit(LIMIT)
        end

        def build_cross_dependencies_fragments(deps, search_scope)
          deps.inject([]) do |fragments, dep|
            next fragments unless dep[:artifacts]

            fragments << build_cross_dependency_relationship_fragment(dep, search_scope)
          end
        end

        def build_cross_dependency_relationship_fragment(dependency, search_scope)
          args = dependency.values_at(:job, :ref, :project)
          dep_id = search_scope.max_build_id_by(*args)

          DEPENDENCY.id_in(dep_id)
        end

        def user
          strong_memoize(:user) do
            processable.user
          end
        end
      end
    end
  end
end
