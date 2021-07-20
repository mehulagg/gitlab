# frozen_string_literal: true

module EE
  module ProfilesHelper
    extend ::Gitlab::Utils::Override

    override :ssh_key_expiration_tooltip
    def ssh_key_expiration_tooltip(key)
      return super unless ::Key.expiration_enforced? && key.expired?

      key.only_expired_and_enforced? ? s_('Profiles|Expired key is not valid.') : s_('Profiles|Invalid key.')
    end

    override :ssh_key_expires_field_description
    def ssh_key_expires_field_description
      return super unless ::Key.expiration_enforced?

      s_('Profiles|Key will be deleted on this date.')
    end
  end
end
