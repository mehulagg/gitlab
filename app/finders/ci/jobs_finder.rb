# frozen_string_literal: true

module Ci
  class JobsFinder
    include Gitlab::Allowable

    def initialize(pipeline: nil, project: nil, params: {}, type: ::Ci::Build)
      @pipeline = pipeline
      @project = project
      @params = params
      @type = type
      raise ArgumentError 'type must be a subclass of Ci::Processable' unless type < ::Ci::Processable
    end

    def execute
      builds = init_collection.order_id_desc
      filter_by_scope(builds)
    rescue Gitlab::Access::AccessDeniedError
      type.none
    end

    private

    attr_reader :pipeline, :project, :params, :type

    def init_collection
      if Feature.enabled?(:ci_jobs_finder_refactor)
        pipeline_jobs || project_jobs || all_jobs
      else
        project ? project_builds : all_jobs
      end
    end

    def all_jobs
      type.all
    end

    def project_builds
      project.builds.relevant
    end

    def project_jobs
      return unless project

      jobs_by_type(project, type).relevant
    end

    def pipeline_jobs
      return unless pipeline

      jobs_by_type(pipeline, type).latest
    end

    def filter_by_scope(builds)
      if Feature.enabled?(:ci_jobs_finder_refactor)
        return filter_by_statuses!(params[:scope], builds) if params[:scope].is_a?(Array)
      end

      case params[:scope]
      when 'pending'
        builds.pending.reverse_order
      when 'running'
        builds.running.reverse_order
      when 'finished'
        builds.finished
      else
        builds
      end
    end

    def filter_by_statuses!(statuses, builds)
      unknown_statuses = params[:scope] - ::CommitStatus::AVAILABLE_STATUSES
      raise ArgumentError, 'Scope contains invalid value(s)' unless unknown_statuses.empty?

      builds.where(status: params[:scope]) # rubocop: disable CodeReuse/ActiveRecord
    end

    def jobs_by_type(relation, type)
      case type.name
      when ::Ci::Build.name
        relation.builds
      when ::Ci::Bridge.name
        relation.bridges
      else
        raise ArgumentError, "finder does not support #{type} type"
      end
    end
  end
end
