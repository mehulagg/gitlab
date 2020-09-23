# frozen_string_literal: true

class LicenseEntity < Grape::Entity
  class ComponentEntity < Grape::Entity
    expose :name
    expose :path, as: :blob_path
  end

  expose :id
  expose :name
  expose :url do |license|
    license.url.presence
  end
  expose :spdx_identifier
  expose :classification
  expose :dependencies, using: ComponentEntity, as: :components
end
