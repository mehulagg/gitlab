# frozen_string_literal: true

class RemoveDeprecatedModsecurityColumns < ActiveRecord::Migration[6.0]
  include Gitlab::Database::MigrationHelpers

  disable_ddl_transaction!

  INDEX_NAME = 'index_clusters_applications_ingress_on_modsecurity'

  def up
    with_lock_retries do
      remove_column :clusters_applications_ingress, :modsecurity_enabled
      remove_column :clusters_applications_ingress, :modsecurity_mode
    end
  end

  def down
    add_column :clusters_applications_ingress, :modsecurity_enabled, :boolean
    add_column :clusters_applications_ingress, :modsecurity_mode, :smallint, null: false, default: 0

    add_concurrent_index :clusters_applications_ingress, [:modsecurity_enabled, :modsecurity_mode, :cluster_id], name: INDEX_NAME
  end
end
