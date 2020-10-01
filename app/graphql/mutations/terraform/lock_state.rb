# frozen_string_literal: true

module Mutations
  module Terraform
    class LockState < BaseStateMutation
      graphql_name 'TerraformStateLock'

      def resolve(id:)
        state = authorized_find!(id: id)
        state.update(lock_xid: lock_xid, locked_by_user: current_user, locked_at: Time.current)

        { errors: errors_on_object(state) }
      end

      private

      def lock_xid
        SecureRandom.uuid
      end
    end
  end
end
