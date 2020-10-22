# frozen_string_literal: true

module PreventForkingHelper
  def can_change_prevent_forking?(current_user, group)
    can?(current_user, :change_prevent_group_forking, group)
  end
end
