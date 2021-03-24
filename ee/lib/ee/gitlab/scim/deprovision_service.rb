# frozen_string_literal: true

module EE
  module Gitlab
    module Scim
      class DeprovisionService
        attr_reader :identity

        delegate :user, :group, to: :identity

        def initialize(identity)
          @identity = identity
        end

        def execute
          return error(_('Did not remove user from group: User is not a group member.')) unless group_membership
          return error(_('Did not remove user from group: Cannot remove last group owner.')) if group.last_owner?(user)

          ScimIdentity.transaction do
            identity.update!(active: false)
            remove_group_access
            ServiceResponse.success(message: "User #{user.name} has been deprovisioned.")
          end
        end

        private

        def remove_group_access
          ::Members::DestroyService.new(user).execute(group_membership)
        end

        def group_membership
          @group_membership ||= group.group_member(user)
        end

        def error(message)
          ServiceResponse.error(message: message)
        end
      end
    end
  end
end
