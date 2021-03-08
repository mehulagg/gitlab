# frozen_string_literal: true

module Mutations
  module IncidentManagement
    module OncallRotation
      class Update < Base
        include ResolvesProject

        graphql_name 'OncallRotationUpdate'

        argument :id, ::Types::GlobalIDType[::IncidentManagement::OncallRotation],
                 required: true,
                 description: 'The ID of the on-call schedule to create the on-call rotation in.'

        argument :name, GraphQL::STRING_TYPE,
                 required: true,
                 description: 'The name of the on-call rotation.'

        argument :starts_at, Types::IncidentManagement::OncallRotationDateInputType,
                 required: true,
                 description: 'The start date and time of the on-call rotation, in the timezone of the on-call schedule.'

        argument :ends_at, Types::IncidentManagement::OncallRotationDateInputType,
                 required: false,
                 description: 'The end date and time of the on-call rotation, in the timezone of the on-call schedule.'

        argument :rotation_length, Types::IncidentManagement::OncallRotationLengthInputType,
                 required: true,
                 description: 'The rotation length of the on-call rotation.'

        argument :active_period, Types::IncidentManagement::OncallRotationActivePeriodInputType,
                 required: false,
                 description: 'The active period of time that the on-call rotation should take place.'

        argument :participants,
                 [Types::IncidentManagement::OncallUserInputType],
                 required: true,
                 description: 'The usernames of users participating in the on-call rotation.'

        def resolve(id:, participants:, **args)
          rotation = authorized_find!(id: id)

          result = ::IncidentManagement::OncallRotations::EditService.new(
            rotation,
            current_user,
            service_params(rotation.schedule, participants, args)
          ).execute

          response(result)
        end

        private

        def find_object(id:)
          GitlabSchema.object_from_id(id, expected_type: ::IncidentManagement::OncallRotation)
        end

        def raise_rotation_not_found
          raise Gitlab::Graphql::Errors::ArgumentError, 'The rotation could not be found'
        end
      end
    end
  end
end
