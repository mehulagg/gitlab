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
      # @option opts  - participant [User] The user who is part of the rotation
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
        return error_too_many_participants if participants_params && participants_params.size > MAXIMUM_PARTICIPANTS
        return error_duplicate_participants if !participants_params.nil? && duplicated_users?

        # Ensure shift history is up to date before saving new params
        IncidentManagement::OncallRotations::PersistShiftsJob.new.perform(oncall_rotation.id)

        OncallRotation.transaction do
          update_and_remove_participants

          # TODO Recalculate rotation with new params
          # See https://gitlab.com/gitlab-org/gitlab/-/merge_requests/55570

          raise RotationModificationError.new(error_in_validation(oncall_rotation)) unless oncall_rotation.update(params)

          success(oncall_rotation.reload)
        end

      rescue RotationModificationError => err
        err.service_response_error
      end

      private

      attr_reader :oncall_rotation, :user, :project, :params, :participants_params

      def update_and_remove_participants
        participants = participants_for(oncall_rotation)
        raise RotationModificationError.new(error_participant_has_no_permission) if participants.nil?

        first_invalid_participant = participants.find(&:invalid?)
        raise RotationModificationError.new(error_in_validation(first_invalid_participant)) if first_invalid_participant

        upsert_participants(participants)
      end

      def error_no_permissions
        error(_('You have insufficient permissions to edit an on-call rotation in this project'))
      end
    end
  end
end
