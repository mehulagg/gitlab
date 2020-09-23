# frozen_string_literal: true

module GroupSaml
  module SamlProvider
    module BaseService
      extend FastGettext::Translation

      attr_reader :saml_provider, :params, :current_user

      delegate :group, to: :saml_provider

      def initialize(current_user, saml_provider, params:)
        @saml_provider = saml_provider
        @current_user = current_user
        @params = params
      end

      def execute
        ::SamlProvider.transaction do
          group_managed_accounts_was_enforced = saml_provider.enforced_group_managed_accounts?

          updated = saml_provider.update(params)

          if updated && saml_provider.enforced_group_managed_accounts? && !group_managed_accounts_was_enforced
            require_linked_saml_to_enable_group_managed!
            cleanup_members! if ::Feature.enabled?(:gma_member_cleanup)
          end
        end
      end

      private

      def require_linked_saml_to_enable_group_managed!
        return if saml_provider.identities.for_user(current_user).exists?

        add_error!(_("Group Owner must have signed in with SAML before enabling Group Managed Accounts"))
      end

      def cleanup_members!
        return if GroupManagedAccounts::CleanUpMembersService.new(current_user, group).execute

        add_error!(_("Can't remove group members without group managed account"))
      end

      def add_error!(message)
        saml_provider.errors.add(:base, message)

        raise ActiveRecord::Rollback
      end
    end
  end
end
