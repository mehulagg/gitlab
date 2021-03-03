# frozen_string_literal: true

module API
  class MergeRequestJiraIssueLink < ::API::Base
    before { authenticate_non_get! }

    feature_category :source_code_management

    helpers do
      def present_issue_link(merge_request)
        present merge_request, with: ::API::Entities::MergeRequests::JiraIssueLink, current_user: current_user
      end
    end

    resource :projects, requirements: ::API::API::NAMESPACE_OR_PROJECT_REQUIREMENTS do
      segment ':id/merge_requests/:merge_request_iid' do
        # Get the status of the merge request's approvals
        #
        # Parameters:
        #   id (required)                 - The ID of a project
        #   merge_request_iid (required)  - IID of MR
        # Examples:
        #   GET /projects/:id/merge_requests/:merge_request_iid/jira_issue_link
        desc 'List Jira Issue link for merge request'
        get 'jira_issue_link' do
          not_found!("Merge Request") unless can?(current_user, :read_merge_request, user_project)

          merge_request = find_merge_request_with_access(params[:merge_request_iid])

          present_issue_link(merge_request)
        end
      end
    end
  end
end
