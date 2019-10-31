# frozen_string_literal: true

class BuildCreatedWorker
  include ApplicationWorker
  include PipelineQueue
  include CiMetrics

  queue_namespace :pipeline_processing

  # rubocop: disable CodeReuse/ActiveRecord
  def perform(build_id)
    Ci::Build.find_by(id: build_id).try do |build|
      count_created_job(build)
    end
  end
  # rubocop: enable CodeReuse/ActiveRecord
end
