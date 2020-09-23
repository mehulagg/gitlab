# frozen_string_literal: true

module EE
  module Mutations
    module Issues
      module Update
        extend ActiveSupport::Concern

        prepended do
          argument :health_status,
                   ::Types::HealthStatusEnum,
                   required: false,
                   description: 'The desired health status'
          argument :epic_id,
                   GraphQL::ID_TYPE,
                   required: false,
                   description: 'The ID of the parent epic. NULL when removing the association'
        end

        def resolve(project_path:, iid:, **args)
          args[:epic_id] = ::GitlabSchema.parse_gid(args[:epic_id], expected_type: ::Epic).model_id if args[:epic_id]

          super
        end
      end
    end
  end
end
