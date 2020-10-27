# frozen_string_literal: true

# ProjectRepositoryStorageMove are details of repository storage moves for a
# project. For example, moving a project to another gitaly node to help
# balance storage capacity.
class ProjectRepositoryStorageMove < ApplicationRecord
  include RepositoryStorageMoveable

  belongs_to :project, inverse_of: :repository_storage_moves

  validates :project, presence: true

  scope :with_projects, -> { includes(project: :route) }

  state_machine do
    around_transition initial: :scheduled do |storage_move, block|
      block.call

      begin
        storage_move.container.set_repository_read_only!
      rescue => err
        errors.add(:project, err.message)
        next false
      end

      storage_move.run_after_commit do
        ProjectUpdateRepositoryStorageWorker.perform_async(
          storage_move.project_id,
          storage_move.destination_storage_name,
          storage_move.id
        )
      end

      true
    end
  end

  class << self
    def klass
      Project
    end
  end

  def container
    project
  end
end
