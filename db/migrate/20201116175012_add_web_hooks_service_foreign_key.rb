# frozen_string_literal: true

class AddWebHooksServiceForeignKey < ActiveRecord::Migration[6.0]
  include Gitlab::Database::MigrationHelpers

  DOWNTIME = false

  def up
    with_lock_retries do
      add_foreign_key :web_hooks, :services, column: :service_id, on_delete: :cascade, validate: false
    end
  end

  def down
    with_lock_retries do
      remove_foreign_key :web_hooks, column: :service_id
    end
  end
end
