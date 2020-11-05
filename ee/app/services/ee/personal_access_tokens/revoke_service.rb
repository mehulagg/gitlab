# frozen_string_literal: true

module EE
  module PersonalAccessTokens
    module RevokeService
      include ::Gitlab::Allowable
      extend ::Gitlab::Utils::Override

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
    end
  end
end
