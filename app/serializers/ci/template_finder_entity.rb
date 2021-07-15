# frozen_string_literal: true

module Ci
  class TemplateFinderEntity < Grape::Entity
    include Gitlab::Routing
    include Gitlab::Allowable

    expose :class do |finder|
      finder.class.name
    end
  end
end
