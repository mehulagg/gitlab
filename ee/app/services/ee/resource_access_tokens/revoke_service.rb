# frozen_string_literal: true

module EE
  module ResourceAccessTokens
    module RevokeService
      def execute
        super.tap do |response|
          audit_event_service(bot_user, response)
        end
      end

      private

      def audit_event_service(token, response)
        message = if response.success?
                    "Revoked #{resource.class.name.downcase} access token with id: #{bot_user.id}"
                  else
                    "Attempted to revoke #{resource.class.name.downcase} access token with id: #{bot_user.id}, but failed with message: #{response.message}"
                  end

        ::AuditEventService.new(
          current_user,
          resource,
          target_details: bot_user.name,
          action: :custom,
          custom_message: message,
          ip_address: current_user.current_sign_in_ip
        ).security_event
      end
    end
  end
end
