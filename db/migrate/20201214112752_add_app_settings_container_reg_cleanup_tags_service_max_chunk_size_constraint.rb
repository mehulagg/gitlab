# frozen_string_literal: true

class AddAppSettingsContainerRegCleanupTagsServiceMaxChunkSizeConstraint < ActiveRecord::Migration[6.0]
  include Gitlab::Database::MigrationHelpers

  DOWNTIME = false

  CONSTRAINT_NAME = 'app_settings_container_reg_cleanup_tags_max_chunk_size_positive'

  disable_ddl_transaction!

  def up
    add_check_constraint :application_settings, 'container_registry_cleanup_tags_service_max_chunk_size >= 0', CONSTRAINT_NAME
  end

  def down
    remove_check_constraint :application_settings, CONSTRAINT_NAME
  end
end
