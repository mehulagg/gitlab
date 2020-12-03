# frozen_string_literal: true

module API
  module Entities
    class ProjectRepositoryStorageMove < Grape::Entity
      expose :id
      expose :created_at
      expose :human_state_name, as: :state
      expose :source_storage_name
      expose :destination_storage_name
      expose :container, as: :project, using: Entities::ProjectIdentity
    end
  end
end
