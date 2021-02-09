# frozen_string_literal: true

module EE
  module Projects
    module RepositoriesController
      extend ActiveSupport::Concern

      prepended do
        before_action :log_audit_event, only: [:archive]
      end

      private

      def log_audit_event
        AuditEvents::RepositoryDownloadStartedAuditEventService.new(
          current_user,
          repository.project,
          request.remote_ip
        ).for_project.security_event
      end
    end
  end
end
