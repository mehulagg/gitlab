# frozen_string_literal: true

module API
  class ExternalApprovalRules < ::API::Base
    include PaginationParams

    feature_category :source_code_management

    before { authenticate! }
    before { user_project }
    before { check_feature_enabled!(@project) }

    helpers do
      def check_feature_enabled!(project)
        unauthorized! unless project.feature_available?(:compliance_approval_gates) &&
          Feature.enabled?(:ff_compliance_approval_gates, project)
      end
    end

    resource :projects do
      segment ':id/external_approval_rules' do
        params do
          requires :id, type: Integer, desc: 'The ID of the project to associate the rule with'
          requires :name, type: String, desc: 'The approval rule\'s name'
          requires :external_url, type: String, desc: 'The URL to notify when MR receives new commits'
          optional :protected_branch_ids, type: Array[Integer], coerce_with: ::API::Validations::Types::CommaSeparatedToIntegerArray.coerce, desc: 'The protected branch ids for this rule'
          use :pagination
        end
        desc 'Create a new external approval rule' do
          success ::API::Entities::ExternalApprovalRule
          detail 'This feature is gated by the :ff_compliance_approval_gates feature flag.'
        end

        post do
          service = ::ExternalApprovalRules::CreateService.new(container: @project,
                                                               current_user: current_user,
                                                               params: declared(params, include_missing: false)).execute

          if service.success?
            present service.payload[:rule], with: ::API::Entities::ExternalApprovalRule
          else
            render_api_error!(service.payload[:errors], service.http_status)
          end
        end

        desc 'List project\'s external approval rules' do
          detail 'This feature is gated by the :ff_compliance_approval_gates feature flag.'
        end
        get do
          unauthorized! unless current_user.can?(:admin_project, @project)

          present paginate(@project.external_approval_rules), with: ::API::Entities::ExternalApprovalRule
        end
      end
    end
  end
end
