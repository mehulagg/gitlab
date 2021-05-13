# frozen_string_literal: true

class ProtectedTag::CreateAccessLevel < NamespaceShard
  include ProtectedTagAccess

  def check_access(user)
    return false if access_level == Gitlab::Access::NO_ACCESS

    super
  end
end
