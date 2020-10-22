# frozen_string_literal: true

module EE
  module Types
    module Terraform
      module StateType
        extend ActiveSupport::Concern

        prepended do
          field :versions, ::Types::Terraform::StateVersionType.connection_type,
                null: false,
                description: 'Version history of the Terraform state file',
                resolver: ::Resolvers::Terraform::StateVersionsResolver
        end
      end
    end
  end
end
