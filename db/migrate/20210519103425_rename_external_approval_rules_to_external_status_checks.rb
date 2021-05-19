# frozen_string_literal: true

class RenameExternalApprovalRulesToExternalStatusChecks < ActiveRecord::Migration[6.0]
  def change
    rename_table :external_approval_rules_protected_branches, :external_status_checks_protected_branches
    rename_column :external_status_checks_protected_branches, :external_approval_rule_id, :external_status_check_id
    rename_table :external_approval_rules, :external_status_checks
  end
end
