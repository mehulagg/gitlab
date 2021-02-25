# frozen_string_literal: true

module IncidentManagement
  module OncallRotations
    module SharedRotationLogic
      MAXIMUM_PARTICIPANTS = 100

      def participants_for(rotation, participants_params)
        participants_params.map do |participant|
          break unless participant[:user].can?(:read_project, project)

          OncallParticipant.new(
            rotation: rotation,
            user: participant[:user],
            color_palette: participant[:color_palette],
            color_weight: participant[:color_weight]
          )
        end
      end

      def participant_rows(participants)
        participants.map do |participant|
          {
            oncall_rotation_id: participant.oncall_rotation_id,
            user_id: participant.user_id,
            color_palette: OncallParticipant.color_palettes[participant.color_palette],
            color_weight: OncallParticipant.color_weights[participant.color_weight]
          }
        end
      end

      def duplicated_users?
        participant_users != participant_users.uniq
      end

      def participant_users
        @participant_users ||= participants_params.map { |participant| participant[:user] }
      end

      # BulkInsertSafe cannot be used here while OncallParticipant
      # has a has_many association. https://gitlab.com/gitlab-org/gitlab/-/issues/247718
      # We still want to bulk insert to avoid up to MAXIMUM_PARTICIPANTS
      # consecutive insertions, but .insert_all
      # does not include validations. Warning!
      def insert_participants(participants)
        OncallParticipant.insert_all(participant_rows(participants))
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
    end
  end
end
