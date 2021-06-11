# frozen_string_literal: true

# See https://docs.gitlab.com/ee/development/migration_style_guide.html
# for more information on how to write migrations for GitLab.

class ChangeCiMinutesAdditionalPackIndex < ActiveRecord::Migration[6.1]
  include Gitlab::Database::MigrationHelpers

  OLD_INDEX_NAME = 'index_ci_minutes_additional_packs_on_namespace_id_purchase_xid'
  NEW_INDEX_NAME = 'i_ci_minutes_additional_packs_on_namespace_id_purchase_xid_uniq'

  # rubocop:disable Migration/AddIndex
  # rubocop:disable Migration/RemoveIndex
  def up
    return unless Gitlab.com?

    add_index :ci_minutes_additional_packs, [:namespace_id, :purchase_xid], name: NEW_INDEX_NAME, unique: true
    remove_index :ci_minutes_additional_packs, name: OLD_INDEX_NAME
  end

  def down
    return unless Gitlab.com?

    add_index :ci_minutes_additional_packs, [:namespace_id, :purchase_xid], name: OLD_INDEX_NAME
    remove_index :ci_minutes_additional_packs, name: NEW_INDEX_NAME
  end
  # rubocop:enable Migration/AddIndex
  # rubocop:enable Migration/RemoveIndex
end
