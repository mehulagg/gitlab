# frozen_string_literal: true

class RemoveProjectMembersIndex < ActiveRecord::Migration[6.0]
  include Gitlab::Database::MigrationHelpers

  disable_ddl_transaction!

  INDEX = 'index_non_requested_project_members_on_source_id_and_type'

  def up
    remove_concurrent_index_by_name('members', INDEX)
  end

  def down
    add_concurrent_index(:members, [:source_id, :source_type], where: "requested_at IS NULL and type = 'ProjectMember'", name: 'index_non_requested_project_members_on_source_id_and_type')
  end
end
