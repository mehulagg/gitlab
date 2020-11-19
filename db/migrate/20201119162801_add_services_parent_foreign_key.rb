# frozen_string_literal: true

class AddServicesParentForeignKey < ActiveRecord::Migration[6.0]
  include Gitlab::Database::MigrationHelpers

  DOWNTIME = false

  disable_ddl_transaction!

  def up
    remove_foreign_key :services, column: :inherit_from_id
    add_concurrent_foreign_key :services, :services, column: :inherit_from_id, on_delete: :cascade
  end

  def down
    remove_foreign_key :services, column: :inherit_from_id
  end
end
