# frozen_string_literal: true

module API
  class ProjectApprovals < ::Grape::API::Instance
    before { authenticate! }
    before { authorize! :update_approvers, user_project }

    helpers do
      def filter_forbidden_param!(permission, param)
        unless can?(current_user, permission, user_project)
          params.delete(param)
        end
      end

      def filter_params(params)
        filter_forbidden_param!(:modify_merge_request_committer_setting, :merge_requests_disable_committers_approval)
        filter_forbidden_param!(:modify_approvers_rules, :disable_overriding_approvers_per_merge_request)
        filter_forbidden_param!(:modify_merge_request_author_setting, :merge_requests_author_approval)

        params
      end
    end

    params do
      requires :id, type: String, desc: 'The ID of a project'
    end
    resource :projects, requirements: ::API::API::NAMESPACE_OR_PROJECT_REQUIREMENTS do
      segment ':id/approvals' do
        desc 'Get all project approvers and related configuration' do
          detail 'This feature was introduced in 10.6'
          success EE::API::Entities::ApprovalSettings
        end
        get '/' do
          present user_project.present(current_user: current_user), with: EE::API::Entities::ApprovalSettings
        end

        desc 'Change approval-related configuration' do
          detail 'This feature was introduced in 10.6'
          success EE::API::Entities::ApprovalSettings
        end
        params do
          optional :approvals_before_merge, type: Integer, desc: 'The amount of approvals required before an MR can be merged'
          optional :reset_approvals_on_push, type: Boolean, desc: 'Should the approval count be reset on a new push'
          optional :disable_overriding_approvers_per_merge_request, type: Boolean, desc: 'Should MRs be able to override approvers and approval count'
          optional :merge_requests_author_approval, type: Boolean, desc: 'Should merge request authors be able to self approve merge requests; `true` means authors cannot self approve'
          optional :merge_requests_disable_committers_approval, type: Boolean, desc: 'Should committers be able to self approve merge requests'
          optional :require_password_to_approve, type: Boolean, desc: 'Should approvers authenticate via password before adding approval'
          at_least_one_of :approvals_before_merge, :reset_approvals_on_push, :disable_overriding_approvers_per_merge_request, :merge_requests_author_approval, :merge_requests_disable_committers_approval, :require_password_to_approve
        end
        post '/' do
          declared_params = declared(params, include_missing: false, include_parent_namespaces: false)
          project_params = filter_params(declared_params)
          result = ::Projects::UpdateService.new(user_project, current_user, project_params).execute

          if result[:status] == :success
            present user_project.present(current_user: current_user), with: EE::API::Entities::ApprovalSettings
          else
            render_validation_error!(user_project)
          end
        end
      end

      desc 'Update approvers and approver groups' do
        detail 'This feature was introduced in 10.6'
        success EE::API::Entities::ApprovalSettings
      end
      params do
        requires :approver_ids, type: Array[Integer], coerce_with: Validations::Types::CommaSeparatedToIntegerArray.coerce, desc: 'Array of User IDs to set as approvers.'
        requires :approver_group_ids, type: Array[Integer], coerce_with: Validations::Types::CommaSeparatedToIntegerArray.coerce, desc: 'Array of Group IDs to set as approvers.'
      end
      put ':id/approvers' do
        result = ::Projects::UpdateService.new(user_project, current_user, declared(params, include_parent_namespaces: false).merge(remove_old_approvers: true)).execute

        if result[:status] == :success
          present user_project.present(current_user: current_user), with: EE::API::Entities::ApprovalSettings
        else
          render_validation_error!(user_project)
        end
      end
    end
  end
end
