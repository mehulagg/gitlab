# frozen_string_literal: true

module API
  module Entities
    class UserSafe < Grape::Entity
      expose :id, :username
      expose :name, unless: ->(user) { user.project_bot? }
    end
  end
end
