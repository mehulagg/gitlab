# frozen_string_literal: true

module EE
  module PersonalAccessTokens
    module CreateService
      def execute
        super.tap do |response|
          log_audit_event(response.payload[:personal_access_token]) if response.success?
        end
      end

      private

      def log_audit_event(token)
        audit_event_service(token).for_user(full_path: token.user.username, entity_id: token.user.id).security_event
      end

      def audit_event_service(token)
        message = "Created personal access token with id #{token.id}"

        ::AuditEventService.new(
          current_user,
          current_user,
          action: :custom,
          custom_message: message,
          ip_address: @ip_address
        )
      end
    end
  end
end
