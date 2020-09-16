# frozen_string_literal: true

# See https://docs.gitlab.com/ee/development/migration_style_guide.html
# for more information on how to write migrations for GitLab.

class AddIndexesToProductAnalyticsEvents < ActiveRecord::Migration[6.0]
  DOWNTIME = false

  disable_ddl_transaction!

  def change
    add_index :product_analytics_events_experimental, :se_category
    add_index :product_analytics_events_experimental, :se_action
  end
end
