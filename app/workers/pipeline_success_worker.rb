# frozen_string_literal: true

class PipelineSuccessWorker
  include ApplicationWorker
  include PipelineQueue

  queue_namespace :pipeline_processing

  # rubocop: disable CodeReuse/ActiveRecord
  def perform(pipeline_id)
    Ci::Pipeline.find_by(id: pipeline_id).try do |pipeline|
      Ci::PipelineSuccessService.new(pipeline.project, nil).execute(pipeline)
    end
  end
  # rubocop: enable CodeReuse/ActiveRecord
end
