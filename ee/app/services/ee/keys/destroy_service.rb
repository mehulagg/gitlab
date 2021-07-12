# frozen_string_literal: true

module EE
  module Keys
    module DestroyService
      extend ::Gitlab::Utils::Override

      override :destroy_possible?
      def destroy_possible?(key)
        super && !key.is_a?(LDAPKey)
      end

      override :destroy
      def destroy(key)
        super.tap do |destroyed|
          next unless destroyed

          audit_context = {
            name: 'remove_ssh_key',
            author: user,
            scope: key.user,
            target: key,
            message: 'Removed SSH key'
          }

          ::Gitlab::Audit::Auditor.audit(audit_context)
        end
      end
    end
  end
end
