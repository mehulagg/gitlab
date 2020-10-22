# frozen_string_literal: true

module EE
  module API
    module Entities
      class ResourceIterationEvent < Grape::Entity
        expose :id
        expose :user, using: ::API::Entities::UserBasic
        expose :created_at
        expose :resource_type do |event, _options|
          event.issuable.class.name
        end
        expose :resource_id do |event, _options|
          event.issuable.id
        end
        expose :iteration, using: Entities::Iteration
        expose :action
      end
    end
  end
end
