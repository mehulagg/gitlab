# frozen_string_literal: true

module IncidentManagement
  module OncallRotations
    class EditService < OncallRotations::BaseService
      include IncidentManagement::OncallRotations::SharedRotationLogic
      # @param rotation [IncidentManagement::OncallRotation]
      # @param user [User]
      # @param params [Hash<Symbol,Any>]
      # @param params - name [String] The name of the on-call rotation.
      # @param params - length [Integer] The length of the rotation.
      # @param params - length_unit [String] The unit of the rotation length. (One of 'hours', days', 'weeks')
      # @param params - starts_at [DateTime] The datetime the rotation starts on.
      # @param params - ends_at [DateTime] The datetime the rotation ends on.
      # @param params - participants [Array<hash>] An array of hashes defining participants of the on-call rotations.
      # @option opts  - user [User] The user who is part of the rotation
      # @option opts  - color_palette [String] The color palette to assign to the on-call user, for example: "blue".
      # @option opts  - color_weight [String] The color weight to assign to for the on-call user, for example "500". Max 4 chars.
      def initialize(oncall_rotation, user, params)
        @oncall_rotation = oncall_rotation
        @user = user
        @project = oncall_rotation.project
        @params = params
        @participants_params = params.delete(:participants)
      end

      def execute
        return error_no_license unless available?
        return error_no_permissions unless allowed?

        if participants_params
          return error_too_many_participants if participants_params.size > MAXIMUM_PARTICIPANTS
          return error_duplicate_participants if duplicated_users?
          return error_participants_without_permission if users_without_permissions?
        end

        ensure_rotation_is_up_to_date

        OncallRotation.transaction do
          oncall_rotation.update!(params)

          save_participants!
          save_current_shift!

          success(oncall_rotation.reset)
        end

      rescue ActiveRecord::RecordInvalid => err
        error_in_validation(err.record)
      end

      private

      attr_reader :oncall_rotation, :user, :project, :params, :participants_params

      def save_participants!
        return if participants_params.nil?

        super

        oncall_rotation.touch
      end

      def error_no_permissions
        error('You have insufficient permissions to edit an on-call rotation in this project')
      end
    end
  end
end
