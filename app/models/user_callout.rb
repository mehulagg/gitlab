# frozen_string_literal: true

class UserCallout < ActiveRecord::Base
  belongs_to :user

  # All EE-only enums has to be backported to CE
  enum feature_name: {
    gke_cluster_integration: 1,
    gcp_signup_offer: 2,
    cluster_security_warning: 3,
    gold_trial: 4 # EE-only
  }

  validates :user, presence: true
  validates :feature_name,
    presence: true,
    uniqueness: { scope: :user_id },
    inclusion: { in: UserCallout.feature_names.keys }
end
