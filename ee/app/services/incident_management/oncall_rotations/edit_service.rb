# frozen_string_literal: true

module IncidentManagement
  module OncallRotations
    class EditService < OncallRotations::BaseService
      include IncidentManagement::OncallRotations::SharedRotationLogic
      MAXIMUM_PARTICIPANTS = 100

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
        @participants_params = params[:participants]
      end

      def execute
        return error_no_license unless available?
        return error_no_permissions unless allowed?
        return error_too_many_participants if participants_params && participants_params.size > MAXIMUM_PARTICIPANTS
        return error_duplicate_participants if !participants_params.nil? && duplicated_users?

        IncidentManagement::OncallRotations::PersistShiftsJob.new.perform(oncall_rotation.id)

        update_and_remove_participants unless participants_params.nil?
      end

      private

      attr_reader :oncall_rotation, :user, :project, :params, :participants_params

      def update_and_remove_participants
        existing_participants = oncall_rotation.participants

        remove_participants(existing_participants)
        add_participants(existing_participants)
      end

      def remove_participants(existing_participants)
        # Get list of participants that existed, but no longer do
        removed_participants = participant_users.any? ? existing_participants.excluding_users(participant_users) : existing_participants
        removed_participants.mark_as_removed

        removed_participants
      end

      def add_participants(existing_participants)
        retained_users = existing_participants.including_users(participant_users).map(&:user)

        # Find the new participants (participants that are not saved already)
        participant_params_to_add = participants_params.reject { |participant| retained_users.include?(participant[:user]) }

        return unless participant_params_to_add.any?

        participant_objects = participants_for(oncall_rotation, participant_params_to_add)
        insert_participants(participant_objects)
      end

      def error_no_permissions
        error(_('You have insufficient permissions to edit an on-call rotation in this project'))
      end
    end
  end
end
