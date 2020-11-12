# frozen_string_literal: true

module Types
  class DastSiteValidationType < BaseObject
    graphql_name 'DastSiteValidation'
    description 'Represents a DAST Site Validation'

    authorize :create_on_demand_dast_scan

    field :id, ::Types::GlobalIDType[::DastSiteValidation], null: false,
          description: 'ID of the site validation'

    field :status, Types::DastSiteProfileValidationStatusEnum, null: false,
          description: 'The status of the validation',
          resolve: -> (obj, _args, _ctx) { obj.state }
  end
end
