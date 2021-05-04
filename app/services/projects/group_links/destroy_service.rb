# frozen_string_literal: true

module Projects
  module GroupLinks
    class DestroyService < BaseService
      def execute(group_link)
        return false unless group_link

        if group_link.project.private?
          TodosDestroyer::ProjectPrivateWorker.perform_in(Todo::WAIT_FOR_DELETE, project.id)
        else
          TodosDestroyer::ConfidentialIssueWorker.perform_in(Todo::WAIT_FOR_DELETE, nil, project.id)
        end

        group_link.destroy.tap do |link|
          refresh_authorizations_to_project_synchronously(link.project)
        end
      end

      private

      def refresh_authorizations_to_project_synchronously(project)
        AuthorizedProjectUpdate::RefreshProjectAuthorizationsService.new(project).execute
      end
    end
  end
end

Projects::GroupLinks::DestroyService.prepend_if_ee('EE::Projects::GroupLinks::DestroyService')
