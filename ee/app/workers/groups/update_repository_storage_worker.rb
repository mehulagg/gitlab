# frozen_string_literal: true

module Groups
  class UpdateRepositoryStorageWorker # rubocop:disable Scalability/IdempotentWorker
    extend ::Gitlab::Utils::Override
    include ::UpdateRepositoryStorageWorker

    sidekiq_options retry: 3

    private

    override :find_repository_storage_move
    def find_repository_storage_move(repository_storage_move_id)
      ::Groups::RepositoryStorageMove.find(repository_storage_move_id)
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
end
