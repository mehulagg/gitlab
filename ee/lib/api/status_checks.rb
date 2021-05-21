# frozen_string_literal: true

module API
  class StatusChecks < ::API::Base
    feature_category :compliance_management

    before { authenticate! }

    resource :projects, requirements: ::API::API::NAMESPACE_OR_PROJECT_REQUIREMENTS do
      segment ':id/merge_requests/:merge_request_iid/status_check_responses' do
        desc 'Externally approve a merge request' do
          detail 'This feature was introduced in 13.12 and is gated behind the :ff_compliance_approval_gates feature flag.'
          success Entities::MergeRequests::StatusCheckResponse
        end
        params do
          requires :id, type: String, desc: 'The ID of a project'
          requires :merge_request_iid, type: Integer, desc: 'The IID of a merge request'
          requires :external_approval_rule_id, type: Integer, desc: 'The ID of a merge request rule'
          requires :sha, type: String, desc: 'The current SHA at HEAD of the merge request.'
        end
        post do
          not_found! unless ::Feature.enabled?(:ff_compliance_approval_gates, user_project)

          merge_request = find_merge_request_with_access(params[:merge_request_iid], :approve_merge_request)

          check_sha_param!(params, merge_request)

          approval = merge_request.status_check_responses.create(external_approval_rule_id: params[:external_approval_rule_id])

          present(approval, with: Entities::MergeRequests::StatusCheckResponse)
        end
      end
    end
  end
end
