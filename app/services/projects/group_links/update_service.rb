# frozen_string_literal: true

module Projects
  module GroupLinks
    class UpdateService < BaseService
      def initialize(group_link, user = nil)
        super(group_link.project, user)

        @group_link = group_link
      end

      def execute(group_link_params)
        group_link.update!(group_link_params)

        refresh_authorizations if requires_authorization_refresh?(group_link_params)
      end

      private

      attr_reader :group_link

      def refresh_authorizations
        if Feature.enabled?(:use_specialized_worker_for_project_auth_recalculation)
          AuthorizedProjectUpdate::ProjectRecalculateWorker.perform_async(project.id)
        else
          group_link.group.refresh_members_authorized_projects
        end
      end

      def requires_authorization_refresh?(params)
        params.include?(:group_access)
      end
    end
  end
end
