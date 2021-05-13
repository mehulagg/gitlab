# frozen_string_literal: true
module Users
  class UserFollowUser < NamespaceShard
    belongs_to :follower, class_name: 'User'
    belongs_to :followee, class_name: 'User'
  end
end
