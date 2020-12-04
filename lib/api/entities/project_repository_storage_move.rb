# frozen_string_literal: true

module API
  module Entities
    class ProjectRepositoryStorageMove < BasicRepositoryStorageMove
      expose :container, as: :project, using: Entities::ProjectIdentity
    end
  end
end
