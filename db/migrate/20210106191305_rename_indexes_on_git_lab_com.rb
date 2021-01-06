# frozen_string_literal: true

class RenameIndexesOnGitLabCom < ActiveRecord::Migration[6.0]
  include Gitlab::Database::MigrationHelpers

  DOWNTIME = false

  disable_ddl_transaction!

  def up
    rename_index_if_exists :emails, 'emails_email_key', 'index_emails_on_email'
    rename_index_if_exists :ldap_group_links, 'ldap_groups_pkey', 'ldap_group_links_pkey'
    rename_index_if_exists :schema_migrations, 'schema_migrations_version_key', 'schema_migrations_pkey'
    rename_index_if_exists :users, 'users_confirmation_token_key', 'index_users_on_confirmation_token'
    rename_index_if_exists :users, 'users_email_key', 'index_users_on_email'
    rename_index_if_exists :users, 'users_reset_password_token_key', 'index_users_on_reset_password_token'
  end

  def down
    # no-op
  end

  private

  def rename_index_if_exists(table, old_name, new_name)
    return unless index_exists_by_name?(table, old_name)

    with_lock_retries do
      rename_index table, old_name, new_name
    end
  end
end
