# frozen_string_literal: true

class RemoveSeatLinkEnabledFromApplicationSettings < ActiveRecord::Migration[6.1]
  include Gitlab::Database::MigrationHelpers

  disable_ddl_transaction!

  def up
    with_lock_retries do
      remove_column :application_settings, :seat_link_enabled
    end
  end

  def down
    with_lock_retries do
      add_column :application_settings, :seat_link_enabled, :boolean, null: false, default: true
    end
  end
end
