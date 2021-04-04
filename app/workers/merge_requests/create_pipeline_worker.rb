# frozen_string_literal: true

module MergeRequests
  class CreatePipelineWorker # rubocop:disable Scalability/IdempotentWorker
    include ApplicationWorker
    include PipelineQueue

    queue_namespace :pipeline_creation
    feature_category :continuous_integration
    urgency :high
    worker_resource_boundary :cpu
    loggable_arguments 1, 2, 3

    def perform(project_id, user_id, merge_request_id)
      project = Project.find(project_id)
      user = User.find(user_id)
      merge_request = MergeRequest.find(merge_request_id)

      MergeRequests::CreatePipelineService.new(project, user).execute(merge_request)
      merge_request.update_head_pipeline
    end
  end
end
