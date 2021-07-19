# frozen_string_literal: true

module Ci
  class TemplateFinderEntity < Grape::Entity
    include Gitlab::Routing
    include Gitlab::Allowable

    expose :class do |finder|
      finder.class.name
    end

    expose :project, using: ProjectEntity do |finder|
      finder.project if finder.respond_to?(:project)
    end
  end
end
