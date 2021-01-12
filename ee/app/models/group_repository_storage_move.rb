# frozen_string_literal: true

# GroupRepositoryStorageMove are details of repository storage moves for a
# group. For example, moving a group to another gitaly node to help
# balance storage capacity.
class GroupRepositoryStorageMove < ApplicationRecord
  extend ::Gitlab::Utils::Override
  include RepositoryStorageMovable

  belongs_to :container, class_name: 'Group', inverse_of: :repository_storage_moves, foreign_key: :group_id
  alias_attribute :group, :container

  scope :with_groups, -> { includes(container: :route) }

  override :schedule_repository_storage_update_worker
  def schedule_repository_storage_update_worker
    GroupUpdateRepositoryStorageWorker.perform_async(
      group_id,
      destination_storage_name,
      id
    )
  end

  private

  override :error_key
  def error_key
    :group
  end
end
