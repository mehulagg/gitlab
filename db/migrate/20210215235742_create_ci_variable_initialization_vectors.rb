# frozen_string_literal: true

class CreateCiVariableInitializationVectors < ActiveRecord::Migration[6.0]
  include Gitlab::Database::MigrationHelpers

  DOWNTIME = false

  def up
    create_table_with_constraints :ci_variable_initialization_vectors do |t|
      t.timestamps_with_timezone

      t.references :variable, null: false, foreign_key: { to_table: :ci_variables, on_delete: :cascade }, index: true
      t.references :variable_secret_key, null: false,
                   foreign_key: { to_table: :ci_variable_secret_keys, on_delete: :cascade },
                   index: { name: :index_ci_variable_ivs_on_variable_secret_key_id }

      t.text :initialization_vector, null: false, unique: true

      t.text_limit :initialization_vector, 255
    end
  end

  def down
    drop_table :ci_variable_initialization_vectors
  end
end
