# frozen_string_literal: true

module Ci
  class TemplateEntity < Grape::Entity
    include Gitlab::Routing
    include Gitlab::Allowable

    expose :name
    expose :metadata, using: TemplateMetadataEntity
  end
end
