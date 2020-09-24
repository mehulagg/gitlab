# frozen_string_literal: true

module EE
  module IdentityProviderPolicy
    extend ActiveSupport::Concern

    prepended do
      desc "User account is managed by group SAML"
      condition(:group_managed_account, scope: :user) { @user.group_managed_account? }

      desc "Group Managed Accounts is enforced"
      condition(:managed_group, scope: :subject) { @subject.is_a?(SamlProvider) && @subject.enforced_group_managed_accounts? }

      desc "No other Group owners have SSO for this SAML provider"
      condition(:last_group_saml_owner) do
        @subject.is_a?(SamlProvider) && @subject.last_linked_owner?(@user)
      end

      rule { group_managed_account }.prevent_all

      # User is last SSO owner of a managed group
      #
      # Owners without SSO won't have access, this ensures
      # that we don't remove the last owner with access
      #
      # Unlike plain SSO Enforcment, it won't be possible to re-join
      # with SSO if the owner leaves, as they will need to create a
      # new account as a guest with a different email.
      rule { managed_group && last_group_saml_owner }.prevent(:unlink)
    end
  end
end
