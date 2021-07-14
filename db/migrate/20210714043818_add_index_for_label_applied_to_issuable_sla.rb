# frozen_string_literal: true

class AddIndexForLabelAppliedToIssuableSla < ActiveRecord::Migration[6.1]
  include Gitlab::Database::MigrationHelpers

  disable_ddl_transaction!

  INDEX_NAME = 'index_issuable_slas_on_id_due_at_label_applied'

  def up
    add_concurrent_index :issuable_slas, [:id, :due_at], name: INDEX_NAME, where: 'label_applied = FALSE'
  end

  def down
    remove_concurrent_index_by_name :issuable_slas, INDEX_NAME
  end
end
