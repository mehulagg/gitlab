# frozen_string_literal: true

class PipelineFinishedWorker
  include ApplicationWorker
  include PipelineQueue

  queue_namespace :pipeline_processing

  def perform(pipeline_id)
    Ci::Pipeline.find_by_id(pipeline_id).try do |pipeline|
      Ci::PipelineFinishService.new(pipeline.project, pipeline.user).execute(pipeline)
    end
  end
end
