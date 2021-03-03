# frozen_string_literal: true

class AddExcludedUrlsAndRequestHeadersToDastSiteProfiles < ActiveRecord::Migration[6.0]
  include Gitlab::Database::MigrationHelpers

  DOWNTIME = false

  disable_ddl_transaction!

  def up
    with_lock_retries do
      add_column :dast_site_profiles, :authentication_enabled, :boolean
      add_column :dast_site_profiles, :excluded_urls, :text
      add_column :dast_site_profiles, :request_headers, :text
    end

    add_text_limit :dast_site_profiles, :excluded_urls, 1024
    add_text_limit :dast_site_profiles, :request_headers, 1024
  end

  def down
    with_lock_retries do
      remove_column :dast_site_profiles, :request_headers
      remove_column :dast_site_profiles, :excluded_urls
      remove_column :dast_site_profiles, :authentication_enabled
    end
  end
end
