# frozen_string_literal: true

module IncidentManagement
  module OncallRotations
    class CreateService
      MAXIMUM_PARTICIPANTS = 100

      # @param schedule [IncidentManagement::OncallSchedule]
      # @param project [Project]
      # @param current_user [User]
      # @param params [Hash<Symbol,Any>]
      # @param params - name [String] The name of the on-call rotation.
      # @param params - length [Integer] The length of the rotation.
      # @param params - length_unit [String] The unit of the rotation length. (One of 'hours', days', 'weeks')
      # @param params - starts_at [DateTime] The datetime the rotation starts on.
      # @param params - participants [Array<hash>] An array of hashes defining participants of the on-call rotations.
      # @option opts  - participant [User] The user who is part of the rotation
      # @option opts  - color_palette [String] The color palette to assign to the on-call user, for example: "blue".
      # @option opts  - color_weight [String] The color weight to assign to for the on-call user, for example "500". Max 4 chars.
      def initialize(schedule, project, current_user, params)
        @schedule = schedule
        @project = project
        @current_user = current_user
        @rotation_params = params.except(:participants)
        @participants_params = Array(params[:participants])
      end

      def execute
        return error_no_license unless available?
        return error_no_permissions unless allowed?
        return error_too_many_participants if participants_params.size > MAXIMUM_PARTICIPANTS
        return error_duplicate_participants if duplicated_users?

        OncallRotation.transaction do
          oncall_rotation = schedule.rotations.create(rotation_params)
          break error_in_validation(oncall_rotation) unless oncall_rotation.persisted?

          participants = participants_for(oncall_rotation)
          break error_participant_has_no_permission if participants.nil?

          first_invalid_participant = participants.find(&:invalid?)
          break error_in_validation(first_invalid_participant) if first_invalid_participant

          insert_participants(participants)

          success(oncall_rotation)
        end
      end

      private

      attr_reader :schedule, :project, :current_user, :rotation_params, :participants_params

      def allowed?
        Ability.allowed?(current_user, :admin_incident_management_oncall_schedule, project)
      end

      def available?
        ::Gitlab::IncidentManagement.oncall_schedules_available?(project)
      end

      def duplicated_users?
        users = participants_params.map { |participant| participant[:user] }

        users != users.uniq
      end

      def participants_for(rotation)
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

      # BulkInsertSafe cannot be used here while OncallParticipant
      # has a has_many association. https://gitlab.com/gitlab-org/gitlab/-/issues/247718
      # We still want to bulk insert to avoid up to MAXIMUM_PARTICIPANTS
      # consecutive insertions, but .insert_all
      # does not include validations. Warning!
      def insert_participants(participants)
        OncallParticipant.insert_all(participant_rows(participants))
      end

      def error(message)
        ServiceResponse.error(message: message)
      end

      def success(oncall_rotation)
        ServiceResponse.success(payload: { oncall_rotation: oncall_rotation })
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

      def error_no_permissions
        error(_('You have insufficient permissions to create an on-call rotation for this project'))
      end

      def error_no_license
        error(_('Your license does not support on-call rotations'))
      end

      def error_in_validation(object)
        error(object.errors.full_messages.to_sentence)
      end
    end
  end
end
