# frozen_string_literal: true

module IncidentManagement
  module OncallRotations
    class CreateService < OncallRotations::BaseService
      include IncidentManagement::OncallRotations::SharedRotationLogic

      # @param schedule [IncidentManagement::OncallSchedule]
      # @param project [Project]
      # @param user [User]
      # @param params [Hash<Symbol,Any>]
      # @param params - name [String] The name of the on-call rotation.
      # @param params - length [Integer] The length of the rotation.
      # @param params - length_unit [String] The unit of the rotation length. (One of 'hours', days', 'weeks')
      # @param params - starts_at [DateTime] The datetime the rotation starts on.
      # @param params - ends_at [DateTime] The datetime the rotation ends on.
      # @param params - active_period_start [String] The time the on-call shifts should start, for example: "08:00"
      # @param params - active_period_end [String] The time the on-call shifts should end, for example: "17:00"
      # @param params - participants [Array<hash>] An array of hashes defining participants of the on-call rotations.
      # @option opts  - participant [User] The user who is part of the rotation
      # @option opts  - color_palette [String] The color palette to assign to the on-call user, for example: "blue".
      # @option opts  - color_weight [String] The color weight to assign to for the on-call user, for example "500". Max 4 chars.
      def initialize(schedule, project, user, params)
        @schedule = schedule
        @project = project
        @user = user
        @rotation_params = params.except(:participants)
        @participants_params = Array(params[:participants])
      end

      def execute
        return error_no_license unless available?
        return error_no_permissions unless allowed?
        return error_too_many_participants if participants_params.size > MAXIMUM_PARTICIPANTS
        return error_duplicate_participants if duplicated_users?
        return error_participants_without_permission if users_without_permissions?

        OncallRotation.transaction do
          @oncall_rotation = schedule.rotations.create!(rotation_params)

          save_participants!
          save_current_shift!

          success(oncall_rotation.reset)
        end

      rescue ActiveRecord::RecordInvalid => err
        error_in_validation(err.record)
      end

      private

      attr_reader :schedule, :project, :user, :rotation_params, :participants_params, :oncall_rotation

      def error_no_permissions
        error('You have insufficient permissions to create an on-call rotation for this project')
      end
    end
  end
end
