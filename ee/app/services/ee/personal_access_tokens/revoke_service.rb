# frozen_string_literal: true

module EE
  module PersonalAccessTokens
    module RevokeService
      include ::Gitlab::Allowable
      extend ::Gitlab::Utils::Override

      def execute
        super.tap do |response|
          log_audit_event(token, response)
        end
      end

      private

      override :revocation_permitted?

      def revocation_permitted?
        super || managed_user_revocation_allowed?
      end

      def managed_user_revocation_allowed?
        return unless token.present?

        token.user&.group_managed_account? &&
          token.user&.managing_group == group &&
          can?(current_user, :admin_group_credentials_inventory, group)
      end

      def log_audit_event(token, response)
        return unless token.present?

        audit_event_service(token, response).for_user(full_path: token.user.username, entity_id: token.user.id).security_event
      end

      def audit_event_service(token, response)
        message = if response.success?
                    "Revoked personal access token with id #{token.id}"
                  else
                    "Attempted to revoke personal access token with id #{token.id} but failed with message: #{response.message}"
                  end

        ::AuditEventService.new(
          current_user,
          token.user,
          action: :custom,
          custom_message: message
        )
      end
    end
  end
end
