# frozen_string_literal: true

module EE
  module Ci
    module BuildDependencies
      extend ActiveSupport::Concern
      extend ::Gitlab::Utils::Override
      include ::Gitlab::Utils::StrongMemoize

      LIMIT = ::Gitlab::Ci::Config::Entry::Needs::NEEDS_CROSS_DEPENDENCIES_LIMIT

      override :cross_pipeline
      def cross_pipeline
        strong_memoize(:cross_pipeline) do
          fetch_cross_pipeline
        end
      end

      private

      override :valid_cross_pipeline?
      def valid_cross_pipeline?
        cross_pipeline.size == specified_cross_pipeline_dependencies.size
      end

      def fetch_cross_pipeline
        return [] unless processable.user_id
        return [] unless project.feature_available?(:cross_project_pipelines)

        cross_dependencies_relationship
          .preload(project: [:project_feature])
          .select { |job| user.can?(:read_build, job) }
      end

      def cross_dependencies_relationship
        deps = specified_cross_pipeline_dependencies
        return model_class.none unless deps.any?

        relationship_fragments = build_cross_dependencies_fragments(deps, model_class.latest.success)
        return model_class.none unless relationship_fragments.any?

        model_class.from_union(relationship_fragments).limit(LIMIT)
      end

      def build_cross_dependencies_fragments(deps, search_scope)
        deps.inject([]) do |fragments, dep|
          next fragments unless dep[:artifacts]

          fragments << build_cross_dependency_relationship_fragment(dep, search_scope)
        end
      end

      def build_cross_dependency_relationship_fragment(dependency, search_scope)
        args = dependency.values_at(:job, :ref, :project)
        args = args.map { |value| ExpandVariables.expand(value, processable_variables) }

        dep_id = search_scope.max_build_id_by(*args)
        model_class.id_in(dep_id)
      end

      def user
        processable.user
      end

      def processable_variables
        -> { processable.simple_variables_without_dependencies }
      end

      def specified_cross_pipeline_dependencies
        Array(processable.options[:cross_dependencies])
      end
    end
  end
end
