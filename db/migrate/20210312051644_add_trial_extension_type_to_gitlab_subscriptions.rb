# frozen_string_literal: true

class AddTrialExtensionTypeToGitlabSubscriptions < ActiveRecord::Migration[6.0]
  include Gitlab::Database::MigrationHelpers

  DOWNTIME = false

  def up
    with_lock_retries do
      add_column :gitlab_subscriptions, :trial_extension_type, :smallint
      add_column :gitlab_subscription_histories, :trial_extension_type, :smallint
    end
  end

  def down
    with_lock_retries do
      remove_column :gitlab_subscriptions, :trial_extension_type
      remove_column :gitlab_subscription_histories, :trial_extension_type
    end
  end
end
