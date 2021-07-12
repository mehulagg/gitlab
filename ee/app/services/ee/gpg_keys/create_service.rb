# frozen_string_literal: true

module EE
  module GpgKeys
    module CreateService
      extend ::Gitlab::Utils::Override

      override :create
      def create(params)
        super.tap do |key|
          next unless key.persisted?

          audit_context = {
            name: 'add_gpg_key',
            author: user,
            scope: key.user,
            target: key,
            message: 'Added GPG key'
          }

          ::Gitlab::Audit::Auditor.audit(audit_context)
        end
      end
    end
  end
end
