# frozen_string_literal: true

module EE
  module API
    module Entities
      class GroupProtectedEnvironment < Grape::Entity
        expose :tier
        expose :deploy_access_levels, using: ::API::Entities::ProtectedRefAccess
      end
    end
  end
end
