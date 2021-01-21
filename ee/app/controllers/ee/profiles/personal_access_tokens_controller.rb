# frozen_string_literal: true

module EE
  module Profiles::PersonalAccessTokensController
    extend ::Gitlab::Utils::Override

    private

    override :active_personal_access_tokens
    def active_personal_access_tokens
      return super if ::PersonalAccessToken.expiration_enforced?

      finder(state: 'active_or_expired', sort: 'expires_at_asc').execute
    end
  end
end
