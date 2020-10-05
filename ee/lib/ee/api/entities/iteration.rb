# frozen_string_literal: true

module EE
  module API
    module Entities
      class Iteration < Grape::Entity
        expose :id, :iid
        expose :project_id, if: -> (entity, options) { entity&.project_id }
        expose :group_id, if: -> (entity, options) { entity&.group_id }
        expose :title, :description
        expose :state_enum, as: :state
        expose :created_at, :updated_at
        expose :start_date, :due_date
      end
    end
  end
end
