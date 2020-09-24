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
          ScimIdentity.transaction do
            identity.update!(active: false)
            remove_group_access
          end
        end

        private

        def remove_group_access
          return unless group_membership
          return if group.last_owner?(user)

          ::Members::DestroyService.new(user).execute(group_membership)
        end

        def group_membership
          @group_membership ||= group.group_member(user)
        end
      end
    end
  end
end
