# frozen_string_literal: true

module Ci
  class DestroyPipelineService < BaseService
    PIPELINE_RUNNING_ERROR_MSG = 'A running pipeline cannot be deleted. Please cancel this pipeline before deleting it.'

    def execute(pipeline)
      raise Gitlab::Access::AccessDeniedError unless can?(current_user, :destroy_pipeline, pipeline)

      return ServiceResponse.error(message: PIPELINE_RUNNING_ERROR_MSG) if pipeline_running?(pipeline)

      Ci::ExpirePipelineCacheService.new.execute(pipeline, delete: true)

      pipeline.destroy!

      ServiceResponse.success(message: 'Pipeline successfully destroyed')
    rescue ActiveRecord::RecordNotFound
      ServiceResponse.error(message: 'Pipeline not found')
    end

    def pipeline_running?(pipeline)
      pipeline.running? && Feature.enabled?(:destroy_only_cancelled_pipelines, default_enabled: :yaml)
    end
  end
end
