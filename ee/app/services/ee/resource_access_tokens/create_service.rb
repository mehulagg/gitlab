# frozen_string_literal: true

module EE
  module ResourceAccessTokens
    module CreateService
      def execute
        super.tap do |response|
          log_audit_event(response.payload[:access_token], response)
        end
      end

      private

      def log_audit_event(token, response)
        audit_event_service(token, response).for_user(full_path: token&.user&.username, entity_id: token&.user&.id).security_event
      end

      def audit_event_service(token, response)
        message = if response.success?
                    "Created #{resource_type} access token with id #{token.user.id}"
                  else
                    "Attempted to create #{resource_type} access token but failed with message: #{response.message}"
                  end

        ::AuditEventService.new(
          current_user,
          resource,
          target_details: token&.user&.name,
          action: :custom,
          custom_message: message,
          ip_address: ip_address
        )
      end
    end
  end
end
