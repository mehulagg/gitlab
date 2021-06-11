# frozen_string_literal: true

class InsertPagesFileEntriesPlanLimits < ActiveRecord::Migration[6.1]
  include Gitlab::Database::MigrationHelpers

  def up
    create_or_update_plan_limit('pages_file_entries', 'default', 100_000)
    create_or_update_plan_limit('pages_file_entries', 'free', 100_000)
    create_or_update_plan_limit('pages_file_entries', 'bronze', 100_000)
    create_or_update_plan_limit('pages_file_entries', 'silver', 100_000)
    create_or_update_plan_limit('pages_file_entries', 'gold', 100_000)
  end
end
