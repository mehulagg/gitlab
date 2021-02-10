# frozen_string_literal: true

module EE
  module Projects
    module ProtectedBranchesController
      extend ::Gitlab::Utils::Override

      protected

      override :protected_ref_params
      def protected_ref_params(*attrs)
        params_hash = super(:code_owner_approval_required)

        params_hash[:code_owner_approval_required] = false unless project.code_owner_approval_required_available?

        params_hash
      end
    end
  end
end
