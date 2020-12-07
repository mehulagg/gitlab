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
        @params = params
      end

      def execute
        return error_no_license unless available?
        return error_no_permissions unless allowed?

        participant_params = Array(params[:participants])

        return error_too_many_participants if participant_params.size > MAXIMUM_PARTICIPANTS

        participants = participant_params.map do |participant|
          OncallParticipant.new(
            user: participant[:user],
            color_palette: participant[:color_palette],
            color_weight: participant[:color_weight]
          )
        end

        oncall_rotation = schedule.rotations.create(
          **params.except(:participants),
          participants: participants
        )

        return error_in_create(oncall_rotation) unless oncall_rotation.persisted?

        success(oncall_rotation)
      end

      private

      attr_reader :schedule, :project, :current_user, :params, :participants

      def allowed?
        Ability.allowed?(current_user, :admin_incident_management_oncall_schedule, project)
      end

      def available?
        ::Gitlab::IncidentManagement.oncall_schedules_available?(project)
      end

      def error(message)
        ServiceResponse.error(message: message)
      end

      def success(oncall_rotation)
        ServiceResponse.success(payload: { oncall_rotation: oncall_rotation })
      end

      def error_too_many_participants
        error("A maximum of #{MAXIMUM_PARTICIPANTS} participants can be added")
      end

      def error_no_permissions
        error('You have insufficient permissions to create an on-call rotation for this project')
      end

      def error_no_license
        error('Your license does not support on-call rotations')
      end

      def error_in_create(oncall_rotation)
        error(oncall_rotation.errors.full_messages.to_sentence)
      end
    end
  end
end
