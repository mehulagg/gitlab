# frozen_string_literal: true

class ChangeGroupWikiRepositoryRegistryLastSyncFailureToString < ActiveRecord::Migration[6.0]
  include Gitlab::Database::MigrationHelpers

  DOWNTIME = false

  disable_ddl_transaction!

  def up
    # rubocop:disable Migration/RemoveColumn
    # We don't need to do this in a post-deployment migration because:
    # * Self-managed installations: This column was just added in the same
    #   release, so it is still unused.
    # * GitLab.com: Geo is not used.
    remove_column(:group_wiki_repository_registry, :last_sync_failure)
    # rubocop:enable Migration/RemoveColumn

    # rubocop:disable Migration/PreventStrings
    # Changing type from text to string because the Geo schema.rb does not
    # support text limit contraints, and therefore if we don't do this, then new
    # installations will have an unlimited text field. Long term, Geo needs to
    # switch to `structure.sql` so we can use text limits.
    # See https://gitlab.com/gitlab-org/gitlab/-/issues/324274.
    add_column(:group_wiki_repository_registry, :last_sync_failure, :string, limit: 255)
    # rubocop:enable Migration/PreventStrings
  end

  def down
    remove_column(:group_wiki_repository_registry, :last_sync_failure) if column_exists?(:group_wiki_repository_registry, :last_sync_failure)
    add_column(:group_wiki_repository_registry, :last_sync_failure, :text)
    add_text_limit(:group_wiki_repository_registry, :last_sync_failure, 255)
  end
end
