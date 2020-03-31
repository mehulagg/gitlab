# frozen_string_literal: true

module Ci
  class Processable
    class Dependencies
      attr_reader :processable

      def initialize(processable)
        @processable = processable
      end

      def all
        (local + cross_pipeline).uniq
      end

      # Dependencies local to the given pipeline
      def local
        return [] if no_local_dependencies_specified?

        deps = model_class.where(pipeline_id: processable.pipeline_id).latest
        deps = from_previous_stages(deps)
        deps = from_needs(deps)
        deps = from_dependencies(deps)
        deps
      end

      # Dependencies that are defined in other pipelines
      def cross_pipeline
        []
      end

      def invalid_local
        local.reject(&:valid_dependency?)
      end

      def valid?
        valid_local? && valid_cross_pipeline?
      end

      def cache!
        processable.options[:dependency_ids] = all.map(&:id)
        processable.save!
      end

      def cached?
        !processable.options[:dependency_ids].nil?
      end

      def all_from_cache
        @cached_dependencies ||= model_class.id_in(processable.options[:dependency_ids])
      end

      def valid_cached?
        all_from_cache.all?(&:valid_dependency?)
      end

      private

      # Dependencies can only be of Ci::Build type because only builds
      # can create artifacts
      def model_class
        ::Ci::Build
      end

      def valid_local?
        return true if Feature.enabled?('ci_disable_validates_dependencies')

        local.all?(&:valid_dependency?)
      end

      def valid_cross_pipeline?
        true
      end

      def project
        processable.project
      end

      def no_local_dependencies_specified?
        processable.options[:dependencies]&.empty?
      end

      def from_previous_stages(scope)
        scope.before_stage(processable.stage_idx)
      end

      def from_needs(scope)
        return scope unless Feature.enabled?(:ci_dag_support, project, default_enabled: true)
        return scope unless processable.scheduling_type_dag?

        needs_names = processable.needs.artifacts.select(:name)
        scope.where(name: needs_names)
      end

      def from_dependencies(scope)
        return scope unless processable.options[:dependencies].present?

        scope.where(name: processable.options[:dependencies])
      end
    end
  end
end

Ci::Processable::Dependencies.prepend_if_ee('EE::Ci::Processable::Dependencies')
