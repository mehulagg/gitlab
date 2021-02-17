# frozen_string_literal: true

module EE
  module Types
    module Ci
      module CiCdSettingType
        extend ActiveSupport::Concern

        prepended do
          field :merge_pipelines_enabled, GraphQL::BOOLEAN_TYPE, null: true,
            description: 'Whether merge pipelines are enabled.',
            method: :merge_pipelines_enabled?
          field :merge_trains_enabled, GraphQL::BOOLEAN_TYPE, null: true,
            description: 'Whether merge trains are enabled.',
            method: :merge_trains_enabled?
        end
      end
    end
  end
end
