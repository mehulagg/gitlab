# frozen_string_literal: true

class AddEnforcedGitCheckToSamlProvider < ActiveRecord::Migration[6.0]
  include Gitlab::Database::MigrationHelpers

  DOWNTIME = false

  def up
    with_lock_retries do
      add_column :saml_providers, :git_check_enforced, :boolean, default: false, null: false
    end
  end

  def down
    with_lock_retries do
      remove_column :saml_providers, :git_check_enforced
    end
  end
end
