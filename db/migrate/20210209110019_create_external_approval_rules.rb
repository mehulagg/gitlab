# frozen_string_literal: true

class CreateExternalApprovalRules < ActiveRecord::Migration[6.0]
  include Gitlab::Database::MigrationHelpers

  DOWNTIME = false

  def up
    create_table_with_constraints :external_approval_rules do |t|
      t.references :project, foreign_key: true
      t.text :external_url, null: false
      t.text_limit :external_url, 255

      t.timestamps_with_timezone
    end

    create_table :external_approval_rules_protected_branches do |t|
      t.references :external_approval_rule, foreign_key: true, index: { name: 'external_approval_rules_protected_branches_ear_idx' }
      t.references :protected_branch, foreign_key: true, index: { name: 'external_approval_rules_protected_branches_pb_idx' }
    end
  end

  def down
    drop_table :external_approval_rules, force: :cascade
    drop_table :external_approval_rules_protected_branches, force: :cascade
  end
end
