# frozen_string_literal: true

class CreateTests < ActiveRecord::Migration[6.0]
  include Gitlab::Database::MigrationHelpers

  disable_ddl_transaction!

  def up
    create_table :tests do |t|
      t.integer :columns_are_great
      t.text :heres_more_data
    end

    add_text_limit :tests, :heres_more_data, 255
  end

  def down
    drop_table :tests
  end
end
