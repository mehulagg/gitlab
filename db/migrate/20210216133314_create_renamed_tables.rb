# frozen_string_literal: true

class CreateRenamedTables < ActiveRecord::Migration[6.0]
  include Gitlab::Database::MigrationHelpers

  DOWNTIME = false

  def change
    create_table_with_constraints :renamed_tables do |t|
      t.text :old_name, null: false
      t.text :new_name, null: false

      t.text_limit :old_name, 255
      t.text_limit :new_name, 255

      t.index [:old_name, :new_name], unique: true
    end
  end
end
