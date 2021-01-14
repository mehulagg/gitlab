# frozen_string_literal: true

class AddJobIdsToJiraConnectSubscription < ActiveRecord::Migration[6.0]
  DOWNTIME = false

  def change
    add_column :jira_connect_subscriptions, :job_ids, :jsonb
  end
end
