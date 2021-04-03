# frozen_string_literal: true

module API
  module Entities
    module Groups
      class RepositoryStorageMove < ::API::Entities::BasicRepositoryStorageMove
        expose :group, using: ::API::Entities::BasicGroupDetails
      end
    end
  end
end
