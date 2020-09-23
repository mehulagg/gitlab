# frozen_string_literal: true

module EE
  module GroupMemberPresenter
    def group_sso?
      member.user.group_sso?(source)
    end

    def group_managed_account?
      member.user.group_managed_account?
    end

    private

    def override_member_permission
      :override_group_member
    end
  end
end
