# frozen_string_literal: true

module EE
  module Projects
    module ImportService
      extend ::Gitlab::Utils::Override

      override :after_execute_hook
      def after_execute_hook
        super

        log_audit_event if project.group.present?
      end

      private

      def log_audit_event
        ::AuditEventService.new(
          current_user,
          project.group,
          action: :custom,
          custom_message: 'Project imported'
        ).for_repository_import(project.full_path).security_event
      end
    end
  end
end
