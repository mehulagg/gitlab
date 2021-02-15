# frozen_string_literal: true

class CreateCiVariableSecretKeys < ActiveRecord::Migration[6.0]
  include Gitlab::Database::MigrationHelpers

  DOWNTIME = false

  def up
    create_table_with_constraints :ci_variable_secret_keys do |t|
      t.timestamps_with_timezone

      t.text :encrypted_secret_key, null: false
      t.text :encrypted_secret_key_iv, null: false, unique: true
      t.text :encrypted_secret_key_salt, null: false

      t.text_limit :encrypted_secret_key, 255
      t.text_limit :encrypted_secret_key_iv, 255
      t.text_limit :encrypted_secret_key_salt, 255
    end
  end

  def down
    drop_table :ci_variable_secret_keys
  end
end
