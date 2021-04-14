# frozen_string_literal: true

module IncidentManagement
  module OncallRotations
    module SharedRotationLogic
      MAXIMUM_PARTICIPANTS = 100

      def ensure_rotation_is_up_to_date
        # Ensure shift history is up to date before saving new params
        IncidentManagement::OncallRotations::PersistShiftsJob.new.perform(oncall_rotation.id)
      end

      def save_participants!
        participants = participants_for(oncall_rotation).each(&:validate!)

        upsert_participants(participants)
      end

      # Merge the new expected attributes over the existing
      # participant's attributes to apply any changes.
      def participants_for(oncall_rotation)
        existing_participants_by_user.merge(expected_participants_by_user) do |_, existing_participant, expected_participant|
          existing_participant.assign_attributes(expected_participant.attributes.except('id'))
          existing_participant
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

      def expected_participants_by_user
        participants_params.to_h do |participant|
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
        oncall_rotation.upsert_participants!(participant_rows(participants))
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

      def users_without_permissions?
        DeclarativePolicy.subject_scope do
          participant_users.any? { |user| !user.can?(:read_project, project) }
        end
      end

      def participant_users
        @participant_users ||= participants_params.map { |participant| participant[:user] }
      end

      # Used to accurately record shift history when rotations
      # are created or edited. Any currently running shift will
      # be cut short and a new shift will be saved starting
      # at the creation/update time.
      def save_current_shift!
        existing_shift&.update!(ends_at: oncall_rotation.updated_at)
        new_shift&.update!(starts_at: oncall_rotation.updated_at)
      end

      def existing_shift
        oncall_rotation.shifts.for_timestamp(oncall_rotation.updated_at).first
      end

      def new_shift
        IncidentManagement::OncallShiftGenerator.new(oncall_rotation).for_timestamp(oncall_rotation.updated_at)
      end

      def error_participants_without_permission
        error('A participant has insufficient permissions to access the project')
      end

      def error_too_many_participants
        error('A maximum of %{count} participants can be added' % { count: MAXIMUM_PARTICIPANTS })
      end

      def error_duplicate_participants
        error('A user can only participate in a rotation once')
      end

      def error_in_validation(object)
        error(object.errors.full_messages.to_sentence)
      end
    end
  end
end
