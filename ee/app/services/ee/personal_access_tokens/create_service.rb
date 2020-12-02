# frozen_string_literal: true

module EE
  module PersonalAccessTokens
    module CreateService
      def execute
        super.tap do |response|
          log_audit_event(response.payload[:personal_access_token], response)
        end
      end

      private

      def log_audit_event(token, response)
        audit_event_service(token, response).for_user(full_path: target_user.username, entity_id: target_user.id).security_event
      end

      def audit_event_service(token, response)
        message = if response.success?
                    if token.user.project_bot?
                      "Created project access token with id #{token.id}"
                    else
                      "Created personal access token with id #{token.id}"
                    end
                  else
                    "Attempted to create personal access token but failed with message: #{response.message}"
                  end

        ::AuditEventService.new(
          current_user,
          target_user,
          action: :custom,
          custom_message: message,
          ip_address: ip_address
        )
      end
    end
  end
end
