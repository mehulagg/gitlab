# frozen_string_literal: true

class GroupUpdateRepositoryStorageWorker # rubocop:disable Scalability/IdempotentWorker
  extend ::Gitlab::Utils::Override
  include UpdateRepositoryStorageWorker

  private

  override :source_repository_storage
  def source_repository_storage(container)
    container.wiki.repository_storage
  end

  override :find_repository_storage_move
  def find_repository_storage_move(repository_storage_move_id)
    ::GroupRepositoryStorageMove.find(repository_storage_move_id)
  end

  override :find_container
  def find_container(container_id)
    ::Group.find(container_id)
  end

  override :update_repository_storage
  def update_repository_storage(repository_storage_move)
    ::Groups::UpdateRepositoryStorageService.new(repository_storage_move).execute
  end
end
