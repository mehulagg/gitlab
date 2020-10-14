# frozen_string_literal: true

module EE
  module Mutations
    module Issues
      module CommonMutationArguments
        extend ActiveSupport::Concern

        included do
          argument :health_status,
                   ::Types::HealthStatusEnum,
                   required: false,
                   description: 'The desired health status'

          argument :weight, GraphQL::INT_TYPE,
                   required: false,
                   description: 'The weight of the issue'
        end
      end
    end
  end
end
