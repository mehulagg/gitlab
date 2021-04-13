# frozen_string_literal: true

module EE
  module ProfilesHelper
    extend ::Gitlab::Utils::Override

    override :ssh_key_expiration_tooltip
    def ssh_key_expiration_tooltip(key)
      return super unless ::Key.expiration_enforced? && key.expired?

      # The key returns a validation error for an invalid keys which is displayed in git related operations.
      # However, on the UI we don't want to show this message,
      # so we strip it out and check for any other errors
      return s_('Profiles|Invalid key.') unless key.errors.full_messages.reject do |m|
        m.eql?('Key has expired and the instance administrator has enforced expiration')
      end.empty?

      s_('Profiles|Expired key is not valid.')
    end

    override :ssh_key_expires_field_description
    def ssh_key_expires_field_description
      return super unless ::Key.expiration_enforced?

      s_('Profiles|Key will be deleted on this date.')
    end
  end
end
