# frozen_string_literal: true

module EE
  module Key
    extend ActiveSupport::Concern

    prepended do
      include UsageStatistics

      scope :ldap, -> { where(type: 'LDAPKey') }

      validate :expiration, if: -> { ::Key.expiration_enforced? }

      def expiration
        errors.add(:key, 'has expired and the instance administrator has enforced expiration') if expired?
      end
    end

    class_methods do
      def regular_keys
        where(type: ['LDAPKey', 'Key', nil])
      end

      def expiration_enforced?
        return false unless enforce_ssh_key_expiration_feature_available?

        ::Gitlab::CurrentSettings.enforce_ssh_key_expiration?
      end

      def enforce_ssh_key_expiration_feature_available?
        License.feature_available?(:enforce_ssh_key_expiration) && ::Feature.enabled?(:ff_enforce_ssh_key_expiration)
      end
    end
  end
end
