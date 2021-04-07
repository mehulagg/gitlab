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
          return error(_("Could not remove %{user} from %{group}. User is not a group member.") % { user: user.name, group: group.name }) unless group_membership
          return error(_("Could not remove %{user} from %{group}. Cannot remove last group owner.") % { user: user.name, group: group.name }) if group.last_owner?(user)

          ScimIdentity.transaction do
            identity.update!(active: false)
            remove_group_access
          end

          ServiceResponse.success(message: _("User %{user} was removed from %{group}.") % { user: user.name, group: group.name })
        end

        private

        def remove_group_access
          ::Members::DestroyService.new(user).execute(group_membership)
        end

        def group_membership
          @group_membership ||= group.all_group_members.with_user(user).first
        end

        def error(message)
          ServiceResponse.error(message: message)
        end
      end
    end
  end
end
