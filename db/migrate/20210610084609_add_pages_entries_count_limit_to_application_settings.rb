# frozen_string_literal: true

class AddPagesEntriesCountLimitToApplicationSettings < ActiveRecord::Migration[6.1]
  def change
    add_column :application_settings, :pages_entries_count_limit, :integer, default: 0, null: false
  end
end
