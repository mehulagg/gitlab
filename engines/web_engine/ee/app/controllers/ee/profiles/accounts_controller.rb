# frozen_string_literal: true

module EE
  module Profiles::AccountsController
    extend ::Gitlab::Utils::Override

    private

    override :show_view_variables
    def show_view_variables
      group_saml_identities = GroupSamlIdentityFinder.new(user: current_user).all

      super.merge(group_saml_identities: group_saml_identities)
    end
  end
end
