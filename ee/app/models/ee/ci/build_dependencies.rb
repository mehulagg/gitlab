# frozen_string_literal: true

module EE
  module Ci
    module BuildDependencies
      extend ActiveSupport::Concern
      extend ::Gitlab::Utils::Override
      include ::Gitlab::Utils::StrongMemoize

      CROSS_PROJECT_LIMIT = ::Gitlab::Ci::Config::Entry::Needs::NEEDS_CROSS_PROJECT_DEPENDENCIES_LIMIT

      private

      override :cross_project
      def cross_project
        strong_memoize(:cross_project) do
          fetch_cross_project
        end
      end

      override :valid_cross_project?
      def valid_cross_project?
        cross_project.size == specified_cross_project_dependencies.size
      end

      def fetch_cross_project
        return [] unless processable.user_id
        return [] unless project.feature_available?(:cross_project_pipelines)

        cross_dependencies_relationship
          .preload(project: [:project_feature])
          .select { |job| user.can?(:read_build, job) }
      end

      def cross_dependencies_relationship
        deps = specified_cross_project_dependencies
        return model_class.none unless deps.any?

        relationship_fragments = build_cross_project_dependencies_fragments(deps, model_class.latest.success)
        return model_class.none unless relationship_fragments.any?

        model_class.from_union(relationship_fragments).limit(CROSS_PROJECT_LIMIT)
      end

      def build_cross_project_dependencies_fragments(deps, search_scope)
        deps.inject([]) do |fragments, dep|
          next fragments unless dep[:artifacts]

          fragments << build_cross_project_dependency_relationship_fragment(dep, search_scope)
        end
      end

      def build_cross_project_dependency_relationship_fragment(dependency, search_scope)
        args = dependency.values_at(:job, :ref, :project)
        args = args.map { |value| ExpandVariables.expand(value, processable_variables) }

        dep_id = search_scope.max_build_id_by(*args)
        model_class.id_in(dep_id)
      end

      def user
        processable.user
      end

      def specified_cross_project_dependencies
        specified_cross_dependencies.select { |dep| dep[:project] }
      end
    end
  end
end
