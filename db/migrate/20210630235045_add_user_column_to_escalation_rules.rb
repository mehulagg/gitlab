# frozen_string_literal: true

class AddUserColumnToEscalationRules < ActiveRecord::Migration[6.1]
  include Gitlab::Database::MigrationHelpers

  disable_ddl_transaction!

  RULE_USER_INDEX_NAME = 'index_on_user_escalation_rule'

  def up
    add_column :incident_management_escalation_rules, :user_id, :integer, null: true, index: { name: RULE_USER_INDEX_NAME }
    add_concurrent_foreign_key(:incident_management_escalation_rules, :users, column: :user_id, on_delete: :nullify)
  end

  def down
    with_lock_retries do
      remove_column :incident_management_escalation_rules, :user_id
    end
  end
end
