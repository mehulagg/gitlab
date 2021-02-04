# frozen_string_literal: true

class CreateClients < ActiveRecord::Migration[6.0]
  include Gitlab::Database::MigrationHelpers

  DOWNTIME = false

  disable_ddl_transaction!

  def up
    with_lock_retries do
      create_table :clients do |t|
        t.references :group, references: :namespace, column: :group_id, index: true, null: false

        t.timestamps_with_timezone
        t.text :name, null: false
        t.text :description, null: false, default: '' # rubocop:disable Migration/AddLimitToTextColumns
        t.boolean :active, null: false, default: true
      end
    end

    add_text_limit(:clients, :name, 255)
    add_text_limit(:clients, :description, 255)
  end

  def down
    with_lock_retries do
      drop_table :clients
    end
  end
end
