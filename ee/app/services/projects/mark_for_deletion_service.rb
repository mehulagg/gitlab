# frozen_string_literal: true

module Projects
  class MarkForDeletionService < BaseService
    def execute
      return if project.marked_for_deletion?

      result = ::Projects::UpdateService.new(project, current_user, { archived: true, marked_for_deletion_at: Time.now.utc, deleting_user: current_user }).execute
      log_event if result[:status] == :success

      result
    end

    def log_event
      log_audit_event
      Rails.logger.info("User #{current_user.id} marked project #{project.full_path} for deletion") # rubocop:disable Gitlab/RailsLogger
    end

    def log_audit_event
      ::AuditEventService.new(
        current_user,
        project,
        action: :custom,
        custom_message: "Project marked for deletion"
      ).for_project.security_event
    end
  end
end
