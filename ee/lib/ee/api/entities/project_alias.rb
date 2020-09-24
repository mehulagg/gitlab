# frozen_string_literal: true

module EE
  module API
    module Entities
      class ProjectAlias < Grape::Entity
        expose :id, :project_id, :name
      end
    end
  end
end
