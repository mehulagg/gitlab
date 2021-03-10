# frozen_string_literal: true

class AddTrialExtensionFlagToGitlabSubscriptions < ActiveRecord::Migration[6.0]
  include Gitlab::Database::MigrationHelpers

  DOWNTIME = false

  # I think we cannot disable transaction?
  # Because we do expect the gitlab_subscription_histories change happen in the same database transaction.
  # disable_ddl_transaction!

  def up
    with_lock_retries do
      add_column :gitlab_subscriptions, :trial_extension_flag, :smallint
      add_column :gitlab_subscription_histories, :trial_extension_flag, :smallint
    end
  end

  def down
    with_lock_retries do
      remove_column :gitlab_subscriptions, :trial_extension_flag
      remove_column :gitlab_subscription_histories, :trial_extension_flag
    end
  end
end
