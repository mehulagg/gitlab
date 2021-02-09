# frozen_string_literal: true

class GeoDesignRegistryEntity < Grape::Entity
  expose :project_id

  expose :name do |design|
    design.project.path_with_namespace
  end

  expose :state
  expose :last_synced_at
end
