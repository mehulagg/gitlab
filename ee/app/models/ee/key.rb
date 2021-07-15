# frozen_string_literal: true

module EE
  module Key
    extend ActiveSupport::Concern

    include Auditable

    prepended do
      include UsageStatistics

      scope :ldap, -> { where(type: 'LDAPKey') }

      validate :expiration, if: -> { ::Key.expiration_enforced? }

      def expiration
        errors.add(:key, :expired_and_enforced, message: 'has expired and the instance administrator has enforced expiration') if expired?
      end

      # Returns true if the key is:
      # - Expired
      # - Expiration is enforced
      # - Not invalid for any other reason
      def only_expired_and_enforced?
        return false unless ::Key.expiration_enforced? && expired?

        errors.map(&:type).reject { |t| t.eql?(:expired_and_enforced) }.empty?
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
        License.feature_available?(:enforce_ssh_key_expiration)
      end
    end

    def audit_details
      title
    end
  end
end
