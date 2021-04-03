# frozen_string_literal: true

module Security
  class LicensePolicyEntity < Grape::Entity
    expose :name
    expose :dependencies, using: ::LicenseEntity::ComponentEntity
    expose :url

    expose :classification do |entity|
      {
        id: entity.id,
        name: entity.name,
        approval_status: entity.approval_status
      }
    end

    expose :count do |entity|
      entity.dependencies.count
    end
  end
end
