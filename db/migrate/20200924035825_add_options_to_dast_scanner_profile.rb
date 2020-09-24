# frozen_string_literal: true

class AddOptionsToDastScannerProfile < ActiveRecord::Migration[6.0]
  DOWNTIME = false

  def up
    add_column :dast_scanner_profiles, :active_scan, :boolean, default: false, null: false
    add_column :dast_scanner_profiles, :ajax_spider, :boolean, default: false, null: false
    add_column :dast_scanner_profiles, :show_debug_messages, :boolean, default: false, null: false
  end

  def down
    remove_column :dast_scanner_profiles, :active_scan
    remove_column :dast_scanner_profiles, :ajax_spider
    remove_column :dast_scanner_profiles, :show_debug_messages
  end
end
