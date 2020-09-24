# frozen_string_literal: true

module Projects
  class RestoreService < BaseService
    def execute
      return error(_('Project already deleted')) if project.pending_delete?

      result = ::Projects::UpdateService.new(
        project,
        current_user,
        { archived: false,
          marked_for_deletion_at: nil,
          deleting_user: nil }
      ).execute
      log_event if result[:status] == :success

      result
    end

    def log_event
      log_audit_event
      log_info("User #{current_user.id} restored project #{project.full_path}")
    end

    def log_audit_event
      ::AuditEventService.new(
        current_user,
        project,
        action: :custom,
        custom_message: "Project restored"
      ).for_project.security_event
    end
  end
end
