# frozen_string_literal: true

module IncidentManagement
  module OncallRotations
    module SharedRotationLogic
      MAXIMUM_PARTICIPANTS = 100
      RotationModificationError = Class.new(StandardError) do
        attr_reader :service_response_error

        def initialize(service_response_error)
          @service_response_error = service_response_error
        end
      end

      # Merges existing participants with API-provided
      # participants instead of using just the API-provided ones
      def participants_for(oncall_rotation)
        # Exit early if the participants that the caller
        # wants on the rotation don't have permissions.
        return if expected_participants_by_user.nil?

        # Merge the new expected attributes over the existing .
        # participant's attributes to apply any changes
        existing_participants_by_user.merge(expected_participants_by_user) do |user_id, existing, expected|
          existing.assign_attributes(expected.attributes.except('id'))
          existing
        end.values
      end

      def existing_participants_by_user
        oncall_rotation.participants.to_h do |participant|
          # Setting the `is_removed` flag on the AR object
          # means we don't have to write the removal to the DB
          # unless the participant was actually removed
          participant.is_removed = true

          [participant.user_id, participant]
        end
      end

      # this should return {} for new rotations, so the create service could use this too
      def expected_participants_by_user
        participants_params.to_h do |participant|
          break unless participant[:user].can?(:read_project, project)

          [
            participant[:user].id,
            OncallParticipant.new(
              rotation: oncall_rotation,
              user: participant[:user],
              color_palette: participant[:color_palette],
              color_weight: participant[:color_weight],
              is_removed: false
            )
          ]
        end
      end

      def upsert_participants(participants)
        OncallParticipant.upsert_all(
          participant_rows(participants),
          unique_by: :index_inc_mgmnt_oncall_participants_on_user_id_and_rotation_id
        )
      end

      def participant_rows(participants)
        participants.map do |participant|
          {
            oncall_rotation_id: participant.oncall_rotation_id,
            user_id: participant.user_id,
            color_palette: OncallParticipant.color_palettes[participant.color_palette],
            color_weight: OncallParticipant.color_weights[participant.color_weight],
            is_removed: participant.is_removed
          }
        end
      end

      def duplicated_users?
        participant_users != participant_users.uniq
      end

      def participant_users
        @participant_users ||= participants_params.map { |participant| participant[:user] }
      end

      def error_participant_has_no_permission
        error('A participant has insufficient permissions to access the project')
      end

      def error_too_many_participants
        error(_('A maximum of %{count} participants can be added') % { count: MAXIMUM_PARTICIPANTS })
      end

      def error_duplicate_participants
        error(_('A user can only participate in a rotation once'))
      end

      def error_in_validation(object)
        error(object.errors.full_messages.to_sentence)
      end
    end
  end
end
