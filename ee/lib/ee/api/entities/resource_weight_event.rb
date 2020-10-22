# frozen_string_literal: true

module EE
  module API
    module Entities
      class ResourceWeightEvent < Grape::Entity
        expose :id
        expose :user, using: ::API::Entities::UserBasic
        expose :created_at
        expose :issue_id
        expose :weight
      end
    end
  end
end
