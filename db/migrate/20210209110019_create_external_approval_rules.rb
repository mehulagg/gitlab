# frozen_string_literal: true

class CreateExternalApprovalRules < ActiveRecord::Migration[6.0]
  include Gitlab::Database::MigrationHelpers

  DOWNTIME = false

  def up
    create_table_with_constraints :external_approval_rules do |t|
      t.references :project, foreign_key: true
      t.text :external_url, null: false
      t.text_limit :external_url, 255
      t.text :name, null: false
      t.text_limit :name, 255

      t.timestamps_with_timezone
    end

    create_join_table :external_approval_rules, :protected_branches do |t|
      t.index [:external_approval_rule_id, :protected_branch_id], name: 'external_approval_rule_protected_branch_idx'
    end
  end

  def down
    drop_table :external_approval_rules, force: :cascade
    drop_table :external_approval_rules_protected_branches, force: :cascade
  end
end
