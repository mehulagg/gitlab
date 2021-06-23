# frozen_string_literal: true

# See https://docs.gitlab.com/ee/development/migration_style_guide.html
# for more information on how to write migrations for GitLab.

class CreatePendingPartitionDropsTable < ActiveRecord::Migration[6.1]
  include Gitlab::Database::MigrationHelpers


  def change
    create_table :pending_partition_drops do |t|
      t.timestamps null: false
      t.datetime_with_timezone :drop_after, null: false
      t.text :table_name, null: false
      t.text :schema_name, null: false
    end
  end
end
