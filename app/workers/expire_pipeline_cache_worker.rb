# frozen_string_literal: true

class ExpirePipelineCacheWorker
  include ApplicationWorker
  include PipelineQueue

  queue_namespace :pipeline_cache

  # rubocop: disable CodeReuse/ActiveRecord
  def perform(pipeline_id)
    pipeline = Ci::Pipeline.find_by(id: pipeline_id)
    return unless pipeline

    store = Gitlab::EtagCaching::Store.new

    update_etag_cache(pipeline, store)

    triggered_by = pipeline.triggered_by_pipeline
    store.touch(project_pipeline_path(triggered_by.project, triggered_by)) if triggered_by

    pipeline.triggered_pipelines.each do |triggered|
      store.touch(project_pipeline_path(triggered.project, triggered))
    end

    Gitlab::Cache::Ci::ProjectPipelineStatus.update_for_pipeline(pipeline)
  end
  # rubocop: enable CodeReuse/ActiveRecord

  private

  def project_pipelines_path(project)
    Gitlab::Routing.url_helpers.project_pipelines_path(project, format: :json)
  end

  def project_pipeline_path(project, pipeline)
    Gitlab::Routing.url_helpers.project_pipeline_path(project, pipeline, format: :json)
  end

  def commit_pipelines_path(project, commit)
    Gitlab::Routing.url_helpers.pipelines_project_commit_path(project, commit.id, format: :json)
  end

  def new_merge_request_pipelines_path(project)
    Gitlab::Routing.url_helpers.project_new_merge_request_path(project, format: :json)
  end

  def each_pipelines_merge_request_path(pipeline)
    pipeline.all_merge_requests.each do |merge_request|
      paths = [path_for_merge_request(merge_request, merge_request.target_project)]
      paths << path_for_merge_request(merge_request, merge_request.source_project) if merge_request.for_fork?

      yield(paths)
    end
  end

  def path_for_merge_request(merge_request, project)
    Gitlab::Routing.url_helpers.pipelines_project_merge_request_path(project, merge_request, format: :json)
  end

  # Updates ETag caches of a pipeline.
  #
  # This logic resides in a separate method so that EE can more easily extend
  # it.
  #
  # @param [Ci::Pipeline] pipeline
  # @param [Gitlab::EtagCaching::Store] store
  def update_etag_cache(pipeline, store)
    project = pipeline.project

    store.touch(project_pipelines_path(project))
    store.touch(project_pipeline_path(project, pipeline))
    store.touch(commit_pipelines_path(project, pipeline.commit)) unless pipeline.commit.nil?
    store.touch(new_merge_request_pipelines_path(project))
    each_pipelines_merge_request_path(pipeline) do |paths|
      paths.each { |path| store.touch(path) }
    end
  end
end
