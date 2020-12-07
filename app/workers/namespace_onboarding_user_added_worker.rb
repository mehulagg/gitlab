# frozen_string_literal: true

class NamespaceOnboardingUserAddedWorker
  include ApplicationWorker

  feature_category :users
  urgency :low

  idempotent!

  def perform(group_id)
    group = Group.find(group_id)
    return if group.members.count > 1

    NamespaceOnboardingAction.create_action(group, :user_added)
  end
end
