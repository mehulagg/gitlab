# frozen_string_literal: true

module Ci
  module JobTokenScope
    class AddProjectService < ::BaseService
      include EditScopeValidations

      def execute(target_project)
        validate_edit!(project, target_project, current_user)

        link = ::Ci::JobToken::ProjectScopeLink.new(
          source_project: project,
          target_project: target_project,
          added_by: current_user)

        if link.save
          ServiceResponse.success(payload: { project_link: link })
        else
          ServiceResponse.error(message: link.errors.full_messages.to_sentence, payload: { project_link: link })
        end
      rescue ActiveRecord::RecordNotUnique
        ServiceResponse.error(message: "Target project is already in the job token scope")
      rescue EditScopeValidations::ValidationError => e
        ServiceResponse.error(message: e.message)
      end
    end
  end
end
