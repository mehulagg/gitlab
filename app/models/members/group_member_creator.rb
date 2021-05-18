# frozen_string_literal: true

module Members
  class GroupMemberCreator < Creator
    private

    def access_levels
      Gitlab::Access.sym_options_with_owner
    end

    def can_update_member?
      # There is no current user for bulk actions, in which case anything is allowed
      !current_user || current_user.can?(:update_group_member, member)
    end
  end
end
