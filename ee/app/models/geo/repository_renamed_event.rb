module Geo
  class RepositoryRenamedEvent < ActiveRecord::Base
    include Geo::Model

    belongs_to :project

    validates :project, :repository_storage_name, :repository_storage_path,
              :old_path_with_namespace, :new_path_with_namespace,
              :old_wiki_path_with_namespace, :new_wiki_path_with_namespace,
              :old_path, :new_path, presence: true
  end
end
