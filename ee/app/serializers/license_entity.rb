# frozen_string_literal: true

class LicenseEntity < Grape::Entity
  class ComponentEntity < Grape::Entity
    expose :name
    expose :version
    expose :package_manager
    expose :blob_path do |model, options|
      model.blob_path_for(options[:project])
    end
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
