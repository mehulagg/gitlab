# frozen_string_literal: true

class CreateIssuesRelativePositions < ActiveRecord::Migration[6.0]
  include Gitlab::Database::MigrationHelpers

  DOWNTIME = false

  def change
    create_table :issues_relative_positions, if_not_exists: true do |t|
      t.references :issue, foreign_key: { on_delete: :cascade }, index: true, null: false
      t.bigint :relative_position
      t.integer :bucket, limit: 2
      t.integer :clumped_position, default: 0
      t.index %i[bucket relative_position], name: 'idx_issues_relative_positions_on_bucket_and_relative_position'
    end
  end
end
