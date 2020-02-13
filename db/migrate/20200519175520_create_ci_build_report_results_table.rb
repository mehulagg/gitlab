# frozen_string_literal: true

class CreateCiBuildReportResultsTable < ActiveRecord::Migration[6.0]
  include Gitlab::Database::MigrationHelpers

  DOWNTIME = false

  def change
    create_table :ci_build_report_results do |t|
      t.references :build, null: false, index: false, foreign_key: { to_table: :ci_builds, on_delete: :cascade }
      t.references :project, null: false, index: false, foreign_key: { on_delete: :cascade }
      t.jsonb :data, null: false, default: {}
    end
  end
end
