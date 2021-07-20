# frozen_string_literal: true

# GitlabSubscriptionHistory records the previous value before change.
# `gitlab_subscription_created` is not used. Because there is no previous value before creation.
class GitlabSubscriptionHistory < ApplicationRecord
  enum change_type: [:gitlab_subscription_created,
                     :gitlab_subscription_updated,
                     :gitlab_subscription_destroyed]
end
