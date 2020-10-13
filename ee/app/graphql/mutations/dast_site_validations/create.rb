# frozen_string_literal: true

module Mutations
  module DastSiteValidations
    class Create < BaseMutation
      include AuthorizesProject

      graphql_name 'DastSiteValidationCreate'

      field :id, ::Types::GlobalIDType[::DastSiteValidation],
            null: true,
            description: 'ID of the site profile.'

      argument :full_path, GraphQL::ID_TYPE,
               required: true,
               description: 'The project the site profile belongs to.'

      argument :dast_site_token_id, ::Types::GlobalIDType[::DastSiteToken],
               required: true,
               description: 'ID of the site token.'

      argument :validation_path, GraphQL::STRING_TYPE,
               required: true,
               description: 'The path to be requested during validation.'

      argument :strategy, Types::DastSiteValidationStrategyEnum,
               required: false,
               description: 'The validation strategy to be used.'

      authorize :create_on_demand_dast_scan

      def resolve(full_path:, dast_site_token_id:, validation_path:, strategy: :text_file)
        # nothing to see here yet...
      end
    end
  end
end
