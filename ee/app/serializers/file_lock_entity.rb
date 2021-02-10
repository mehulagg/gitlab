# frozen_string_literal: true

class FileLockEntity < Grape::Entity
  expose :user, using: API::Entities::UserSafe
end
