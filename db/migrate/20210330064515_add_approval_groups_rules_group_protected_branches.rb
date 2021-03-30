# frozen_string_literal: true

class AddApprovalGroupsRulesGroupProtectedBranches < ActiveRecord::Migration[6.0]
  DOWNTIME = false

  RULE_INDEX_NAME = 'idx_approval_group_rule_protected_branch_rule_id'
  GROUP_INDEX_NAME = 'idx_approval_group_rule_protected_branch_group_id'

  def change
    create_table :approval_group_rules_group_protected_branches, if_not_exists: true do |t|
      t.references :approval_group_rules, null: false, on_delete: :cascade, index: { name: RULE_INDEX_NAME }
      t.references :group_protected_branches, null: false, on_delete: :cascade, index: { name: GROUP_INDEX_NAME }
    end
  end
end
