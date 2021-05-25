# frozen_string_literal: true

class AddDummyMigration < ActiveRecord::Migration[6.0]
  include Gitlab::Database::MigrationHelpers

  def change
    create_table_with_constraints :baz do |t|
      t.timestamps_with_timezone null: false

      t.text_limit :name, 255
    end
  end
end
