# frozen_string_literal: true

module EE
  module PersonalAccessTokens
    module RevokeService
      include ::Gitlab::Allowable
      extend ::Gitlab::Utils::Override

      def execute
        super.tap do |response|
          log_audit_event(token) if response.success?
        end
      end

      private

      override :revocation_permitted?
      def revocation_permitted?
        super || managed_user_revocation_allowed?
      end

      def managed_user_revocation_allowed?
        return unless ::Feature.enabled?(:revoke_managed_users_token, group)

        token.user.group_managed_account? &&
          token.user.managing_group == group &&
          can?(current_user, :admin_group_credentials_inventory, group)
      end

      def log_audit_event(token)
        audit_event_service(token).for_user(full_path: token.user.username, entity_id: token.user.id).security_event
      end

      def audit_event_service(token)
        message = "Revoked personal access token with id #{token.id}"

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
