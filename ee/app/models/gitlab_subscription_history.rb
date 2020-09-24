# frozen_string_literal: true

class GitlabSubscriptionHistory < ApplicationRecord
  enum change_type: [:gitlab_subscription_created,
                     :gitlab_subscription_updated,
                     :gitlab_subscription_destroyed]
end
