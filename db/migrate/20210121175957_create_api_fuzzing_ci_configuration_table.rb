# frozen_string_literal: true

class CreateApiFuzzingCiConfigurationTable < ActiveRecord::Migration[6.0]
  include Gitlab::Database::MigrationHelpers

  DOWNTIME = false

  disable_ddl_transaction!

  def up
    create_table :api_fuzzing_ci_configurations do |t|
      t.integer :scan_mode, null: false
      t.text :target, null: false
      t.text :api_definition, null: false

      t.text :auth_password
      t.text :auth_username
      t.text :scan_profile

      t.references :project, foreign_key: { on_delete: :cascade }, type: :integer, null: false
    end

    add_text_limit :api_fuzzing_ci_configurations, :target, 255
    add_text_limit :api_fuzzing_ci_configurations, :api_definition, 255
    add_text_limit :api_fuzzing_ci_configurations, :auth_password, 255
    add_text_limit :api_fuzzing_ci_configurations, :auth_username, 255
    add_text_limit :api_fuzzing_ci_configurations, :scan_profile, 255
  end

  def down
    drop_table :api_fuzzing_ci_configurations
  end
end
