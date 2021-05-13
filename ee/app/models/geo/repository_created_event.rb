# frozen_string_literal: true

module Geo
  class RepositoryCreatedEvent < NamespaceShard
    include Geo::Model
    include Geo::Eventable

    belongs_to :project

    validates :project, :project_name, :repo_path, :repository_storage_name, presence: true
  end
end
