# frozen_string_literal: true

class CreateDastProfilePipelines < ActiveRecord::Migration[6.0]
  include Gitlab::Database::MigrationHelpers

  DOWNTIME = false

  def up
    table_comment = { owner: 'group::dynamic analysis', description: 'Relationship between DAST Profile and CI Pipeline' }

    create_table_with_constraints :dast_profile_pipelines, comment: table_comment.to_json do |t|
      t.references :dast_profile, null: false, foreign_key: { on_delete: :cascade }
      t.references :ci_pipeline, null: false, foreign_key: { on_delete: :cascade }

      t.timestamps_with_timezone
    end
  end

  def down
    with_lock_retries do
      drop_table :dast_profile_pipelines
    end
  end
end
