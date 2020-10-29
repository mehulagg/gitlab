# frozen_string_literal: true

class CleanupApplicationSettingsToAllowDenyRename < ActiveRecord::Migration[6.0]
  include Gitlab::Database::MigrationHelpers

  disable_ddl_transaction!

  def up
    cleanup_concurrent_column_rename :application_settings, :domain_blacklist_enabled, :domain_denylist_enabled
    cleanup_concurrent_column_rename :application_settings, :domain_blacklist, :domain_denylist
    cleanup_concurrent_column_rename :application_settings, :domain_whitelist, :domain_allowlist
    cleanup_concurrent_column_rename :application_settings, :outbound_local_requests_whitelist, :outbound_local_requests_allowlist
  end

  def down
    undo_cleanup_concurrent_column_rename :application_settings, :domain_blacklist_enabled, :domain_denylist_enabled
    undo_cleanup_concurrent_column_rename :application_settings, :domain_blacklist, :domain_denylist
    undo_cleanup_concurrent_column_rename :application_settings, :domain_whitelist, :domain_allowlist
    undo_cleanup_concurrent_column_rename :application_settings, :outbound_local_requests_whitelist, :outbound_local_requests_allowlist
  end
end
