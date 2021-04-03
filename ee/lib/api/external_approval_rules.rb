# frozen_string_literal: true

module API
  class ExternalApprovalRules < ::API::Base
    include PaginationParams

    feature_category :source_code_management

    before do
      authenticate!
      check_feature_enabled!
    end

    helpers do
      def check_feature_enabled!
        unauthorized! unless user_project.feature_available?(:compliance_approval_gates) &&
          Feature.enabled?(:ff_compliance_approval_gates, user_project)
      end
    end

    resource :projects, requirements: API::NAMESPACE_OR_PROJECT_REQUIREMENTS do
      segment ':id/external_approval_rules' do
        desc 'Create a new external approval rule' do
          success ::API::Entities::ExternalApprovalRule
          detail 'This feature is gated by the :ff_compliance_approval_gates feature flag.'
        end
        params do
          requires :name, type: String, desc: 'The name of the external approval rule'
          requires :external_url, type: String, desc: 'The URL to notify when MR receives new commits'
          optional :protected_branch_ids,
                   type: Array[Integer],
                   coerce_with: ::API::Validations::Types::CommaSeparatedToIntegerArray.coerce,
                   desc: 'The protected branch ids for this rule'
        end
        post do
          service = ::ExternalApprovalRules::CreateService.new(
            container: user_project,
            current_user: current_user,
            params: declared_params(include_missing: false)
          ).execute

          if service.success?
            present service.payload[:rule], with: ::API::Entities::ExternalApprovalRule
          else
            render_api_error!(service.payload[:errors], service.http_status)
          end
        end

        desc 'List project\'s external approval rules' do
          detail 'This feature is gated by the :ff_compliance_approval_gates feature flag.'
        end
        params do
          use :pagination
        end
        get do
          unauthorized! unless current_user.can?(:admin_project, user_project)

          present paginate(user_project.external_approval_rules), with: ::API::Entities::ExternalApprovalRule
        end

        segment ':rule_id' do
          desc 'Delete an external approval rule' do
            detail 'This feature is gated by the :ff_compliance_approval_gates feature flag.'
          end
          params do
            requires :rule_id, type: Integer, desc: 'The ID of the external approval rule'
          end
          delete do
            external_approval_rule = user_project.external_approval_rules.find(params[:rule_id])

            destroy_conditionally!(external_approval_rule) do |external_approval_rule|
              ::ExternalApprovalRules::DestroyService.new(
                container: user_project,
                current_user: current_user
              ).execute(external_approval_rule)
            end
          end

          desc 'Update an external approval rule' do
            success ::API::Entities::ExternalApprovalRule
            detail 'This feature is gated by the :ff_compliance_approval_gates feature flag.'
          end
          params do
            requires :rule_id, type: Integer, desc: 'The ID of the external approval rule'
            optional :name, type: String, desc: 'The name of the approval rule'
            optional :external_url, type: String, desc: 'The URL to notify when MR receives new commits'
            optional :protected_branch_ids,
                     type: Array[Integer],
                     coerce_with: ::API::Validations::Types::CommaSeparatedToIntegerArray.coerce,
                     desc: 'The protected branch ids for this rule'
          end
          put do
            service = ::ExternalApprovalRules::UpdateService.new(
              container: user_project,
              current_user: current_user,
              params: declared_params(include_missing: false)
            ).execute

            if service.success?
              present service.payload[:rule], with: ::API::Entities::ExternalApprovalRule
            else
              render_api_error!(service.payload[:errors], service.http_status)
            end
          end
        end
      end
    end
  end
end
