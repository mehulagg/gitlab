# frozen_string_literal: true

module Ci
  class TemplateMetadataEntity < Grape::Entity
    include Gitlab::Routing
    include Gitlab::Allowable

    expose :name
    expose :desc
    expose :stages
    expose :maintainers
    expose :categories
    expose :usage
    expose :inclusion_type
  end
end
