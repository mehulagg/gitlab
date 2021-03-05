# frozen_string_literal: true

class AddNamespaceForeignKeyToInProductMarketingEmails < ActiveRecord::Migration[6.0]
  include Gitlab::Database::MigrationHelpers

  DOWNTIME = false

  disable_ddl_transaction!

  def up
    add_concurrent_foreign_key :in_product_marketing_emails, :namespaces, column: :namespace_id, on_delete: :cascade
  end

  def down
    with_lock_retries do
      remove_foreign_key :in_product_marketing_emails, column: :namespace_id
    end
  end
end
