# frozen_string_literal: true

class MergeRequests::DeleteSourceBranchWorker
  include ApplicationWorker

  feature_category :source_code_management
  idempotent!

  def perform(merge_request_id, user_id)
    merge_request = MergeRequest.find(merge_request_id)
    user = User.find(user_id)

    ::Branches::DeleteService.new(merge_request.source_project, user)
      .execute(merge_request.source_branch)
  rescue ActiveRecord::RecordNotFound
  end
end
