# frozen_string_literal: true

# See https://docs.gitlab.com/ee/development/migration_style_guide.html
# for more information on how to write migrations for GitLab.

class FinalizePkPushEventPayloadsCleanup < ActiveRecord::Migration[6.1]
  include Gitlab::Database::MigrationHelpers

  TABLE_NAME = 'push_event_payloads'
  COLUMNS = %i(event_id)

  def up
    revert_initialize_conversion_of_integer_to_bigint(TABLE_NAME, COLUMNS)
  end

  def down
    initialize_conversion_of_integer_to_bigint(TABLE_NAME, COLUMNS, primary_key: :event_id)
  end
end
