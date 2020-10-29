# frozen_string_literal: true

class Geo::SnippetRepositoryRegistry < Geo::BaseRegistry
  include Geo::ReplicableRegistry

  MODEL_CLASS = ::SnippetRepository
  MODEL_FOREIGN_KEY = :snippet_repository_id

  belongs_to :snippet_repository, class_name: 'SnippetRepository'

  def self.delete_for_model_ids(ids)
    Geo::SnippetRepositoryRegistry.where(snippet_repository_id: ids).delete_all

    snippet_repositories = SnippetRepository.where(snippet_id: ids)

    snippet_repositories.map do |snippet_repository|
      Geo::RepositoryRegistryRemovalService.new(
        snippet_repository.replicator,
        {
          repository_storage: snippet_repository.repository_storage,
          disk_path: snippet_repository.repository.disk_path,
          full_path: snippet_repository.repository.full_path
        }
      ).execute
    end

    ids
  end
end
