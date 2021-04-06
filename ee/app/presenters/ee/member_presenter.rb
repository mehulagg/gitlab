# frozen_string_literal: true

module EE
  module MemberPresenter
    extend ::Gitlab::Utils::Override

    def can_update?(_user_ids)
      super || can_override?
    end

    override :can_override?
    def can_override?
      can?(current_user, override_member_permission, member)
    end

    private

    def override_member_permission
      raise NotImplementedError
    end
  end
end
