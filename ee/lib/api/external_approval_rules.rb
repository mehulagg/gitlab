# frozen_string_literal: true

module API
  class ExternalApprovalRules < ::API::Base
    before { authenticate! }

    helpers do
      def find_project(id)
        @project = ::Project.find(id)
      end

      def check_feature_enabled!(project)
        unauthorized! unless project.feature_available?(:compliance_approval_gates) &&
          Feature.enabled?(:ff_compliance_approval_gates, project) && current_user.can?(:admin_project, project)
      end
    end

    resource :projects do
      segment ':id/external_approval_rules' do
        params do
          requires :id, type: Integer, desc: 'The ID of the project to associate the rule with'
          requires :name, type: String, desc: 'The approval rule\'s name'
          requires :external_url, type: String, desc: 'The URL to notify when MR receives new commits'
          optional :protected_branch_ids, type: Array[Integer], coerce_with: ::API::Validations::Types::CommaSeparatedToIntegerArray.coerce, desc: 'The protected branch ids for this rule'
        end
        desc 'Create new external approval rule' do
          success ::API::Entities::ExternalApprovalRule
        end
        post do
          find_project(params[:id])
          check_feature_enabled!(@project)

          rule = ExternalApprovalRule.new(name: params[:name],
                                          project_id: params[:id],
                                          external_url: params[:external_url],
                                          protected_branch_ids: params[:protected_branch_ids])

          if rule.save
            present rule, with: ::API::Entities::ExternalApprovalRule
          else
            render_api_error!(rule.errors.full_messages, 400)
          end
        end

        get do
          find_project(params[:id])
          check_feature_enabled!(@project)

          present @project.external_approval_rules, with: ::API::Entities::ExternalApprovalRule
        end
      end
    end
  end
end
