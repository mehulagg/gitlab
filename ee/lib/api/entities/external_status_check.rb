# frozen_string_literal: true

module API
  module Entities
    class ExternalStatusCheck < Grape::Entity
      expose :id
      expose :name
      expose :project_id
      expose :external_url
      expose :protected_branches, using: ::API::Entities::ProtectedBranch
    end
  end
end
