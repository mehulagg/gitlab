# frozen_string_literal: true

module API
  class ProjectApprovalRules < ::Grape::API::Instance
    before { authenticate! }

    helpers ::API::Helpers::ProjectApprovalRulesHelpers

    params do
      requires :id, type: String, desc: 'The ID of a project'
    end
    resource :projects, requirements: ::API::API::NAMESPACE_OR_PROJECT_REQUIREMENTS do
      segment ':id/approval_rules' do
        desc 'Get all project approval rules' do
          success EE::API::Entities::ProjectApprovalRule
        end
        get do
          authorize_create_merge_request_in_project

          present user_project.visible_approval_rules, with: EE::API::Entities::ProjectApprovalRule, current_user: current_user
        end

        desc 'Create new project approval rule' do
          success EE::API::Entities::ProjectApprovalRule
        end
        params do
          use :create_project_approval_rule
        end
        post do
          create_project_approval_rule(present_with: EE::API::Entities::ProjectApprovalRule)
        end

        segment ':approval_rule_id' do
          desc 'Update project approval rule' do
            success EE::API::Entities::ProjectApprovalRule
          end
          params do
            use :update_project_approval_rule
          end
          put do
            update_project_approval_rule(present_with: EE::API::Entities::ProjectApprovalRule)
          end

          desc 'Destroy project approval rule'
          params do
            use :delete_project_approval_rule
          end
          delete do
            destroy_project_approval_rule
          end
        end
      end
    end
  end
end
