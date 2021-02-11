# frozen_string_literal: true

module EE
  module API
    module ProtectedBranches
      extend ActiveSupport::Concern

      BRANCH_ENDPOINT_REQUIREMENTS = ::API::API::NAMESPACE_OR_PROJECT_REQUIREMENTS.merge(name: ::API::API::NO_SLASH_URL_PART_REGEX)

      prepended do
        params do
          requires :id, type: String, desc: 'The ID of a project'
        end
        resource :projects, requirements: ::API::API::NAMESPACE_OR_PROJECT_REQUIREMENTS do
          desc 'Update the code_owner_approval_required state of an existing protected branch' do
            success ::API::Entities::ProtectedBranch
          end
          params do
            requires :name, type: String, desc: 'The name of the branch'

            use :optional_params_ee
          end
          # rubocop: disable CodeReuse/ActiveRecord
          patch ':id/protected_branches/:name', requirements: BRANCH_ENDPOINT_REQUIREMENTS do
            render_api_error!("Feature 'Code Owner Approval Required' is not enabled", 403) unless user_project.code_owner_approval_required_available?

            protected_branch = user_project.protected_branches.find_by!(name: params[:name])

            protected_branch.update_attribute(:code_owner_approval_required, declared_params[:code_owner_approval_required])

            present protected_branch, with: ::API::Entities::ProtectedBranch, project: user_project
          end
          # rubocop: enable CodeReuse/ActiveRecord
        end
      end
    end
  end
end
