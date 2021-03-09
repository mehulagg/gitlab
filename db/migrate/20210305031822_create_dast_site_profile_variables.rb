# frozen_string_literal: true

class CreateDastSiteProfileVariables < ActiveRecord::Migration[6.0]
  include Gitlab::Database::MigrationHelpers

  DOWNTIME = false

  def up
    table_comment = { owner: 'group::dynamic analysis', description: 'Variables used in an DAST on-demand scan' }

    create_table_with_constraints :dast_site_profile_variables, comment: table_comment.to_json do |t|
      t.references :dast_site_profile, null: false, foreign_key: { on_delete: :cascade }

      t.integer :variable_type, null: false, default: 1, limit: 2

      t.timestamps_with_timezone

      # rubocop:disable Migration/AddLimitToTextColumns
      t.text :key, null: false
      # rubocop:enable Migration/AddLimitToTextColumns

      # rubocop:disable Migration/AddLimitToTextColumns
      t.text :encrypted_value, null: false
      t.text :encrypted_value_iv, null: false, unique: true
      # rubocop:enable Migration/AddLimitToTextColumns

      t.index [:dast_site_profile_id, :key], unique: true, name: :index_dast_site_profile_variables_on_site_profile_id_and_key

      t.text_limit :key, 255
    end
  end

  def down
    drop_table :dast_site_profile_variables
  end
end
