# frozen_string_literal: true

module Types
  module IncidentManagement
    # rubocop: disable Graphql/AuthorizeTypes
    class OncallShiftType < BaseObject
      graphql_name 'IncidentManagementOncallShift'
      description 'A block of time for which a participant is on-call.'

      field :participant,
            ::Types::IncidentManagement::OncallParticipantType,
            null: true,
            description: 'Participant assigned to the on-call shift.'

      field :starts_at,
            Types::TimeType,
            null: true,
            description: 'Start time of the on-call shift.'

      field :ends_at,
            Types::TimeType,
            null: true,
            description: 'End time of the on-call shift.'

      def participant
        Gitlab::Graphql::Loaders::OncallParticipantLoader.new(object.participant_id).find
      end
    end
    # rubocop: enable Graphql/AuthorizeTypes
  end
end
