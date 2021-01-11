# frozen_string_literal: true

module API
  module Entities
    class GroupRepositoryStorageMove < ::API::Entities::BasicRepositoryStorageMove
      expose :group, using: ::API::Entities::BasicGroupDetails
    end
  end
end
