# frozen_string_literal: true

class Geo::SnippetRepositoryRegistry < Geo::BaseRegistry
  include Geo::ReplicableRegistry
  include ::Geo::VerifiableRegistry

  MODEL_CLASS = ::SnippetRepository
  MODEL_FOREIGN_KEY = :snippet_repository_id

  belongs_to :snippet_repository, class_name: 'SnippetRepository'
end
