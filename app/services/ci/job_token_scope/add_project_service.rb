# frozen_string_literal: true

module Ci
  module JobTokenScope
    class AddProjectService < ::BaseService
      def execute(target_project)
        unless can?(current_user, :admin_project, project)
          return ServiceResponse.error(message: "Insufficient permissions to modify the job token scope")
        end

        unless target_project
          return ServiceResponse.error(message: "Target project must be provided")
        end

        unless can?(current_user, :read_project, target_project)
          return ServiceResponse.error(message: "Insufficient permissions to add the target project")
        end

        link = ::Ci::JobToken::ProjectScopeLink.new(
          source_project: project,
          target_project: target_project,
          added_by: current_user)

        if link.save
          ServiceResponse.success(payload: { project_link: link })
        else
          ServiceResponse.error(message: link.errors.full_messages.to_sentence, payload: { project_link: link })
        end
      end
    end
  end
end
