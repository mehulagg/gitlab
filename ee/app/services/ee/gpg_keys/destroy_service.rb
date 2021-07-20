# frozen_string_literal: true

module EE
  module GpgKeys
    module DestroyService
      extend ::Gitlab::Utils::Override

      override :execute
      def execute(key)
        super.tap do |destroyed|
          next unless destroyed

          audit_context = {
            name: 'remove_gpg_key',
            author: user,
            scope: key.user,
            target: key,
            message: 'Removed GPG key'
          }

          ::Gitlab::Audit::Auditor.audit(audit_context)
        end
      end
    end
  end
end
