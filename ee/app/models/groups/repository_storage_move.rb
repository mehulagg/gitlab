# frozen_string_literal: true

# Groups::RepositoryStorageMove store details of repository storage moves for a
# group. For example, moving a group to another gitaly node to help
# balance storage capacity.
module Groups
  class RepositoryStorageMove < ApplicationRecord
    self.table_name = 'group_repository_storage_moves'

    belongs_to :container, class_name: 'Group', inverse_of: :repository_storage_moves, foreign_key: :group_id
    alias_attribute :group, :container

    scope :with_groups, -> { includes(container: :route) }
  end
end
