# frozen_string_literal: true

module IncidentManagement
  module OncallRotations
    class EditService < OncallRotations::BaseService
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

      # NOTE, this does a REPLACE operation. We expect all params.
      def execute
        return error_no_license unless available?
        return error_no_permissions unless allowed?
        return error_too_many_participants if participants_params && participants_params.size > MAXIMUM_PARTICIPANTS
        # return error_duplicate_participants if duplicated_users?

        update_and_remove_participants if !participants_params.nil?
      end

      private

      def update_and_remove_participants
        existing_participants = rotation.participants.includes(:user)

        remove_participants(existing_participants)
        add_participants(existing_participants)
      end

      def remove_participants(existing_participants)
        # Get list of participants that existed, but no longer do
        removed_participants = existing_participants.where('user_id NOT IN (?)', participant_users)
        removed_participants.destroy_all

        removed_participants
      end

      def add_participants(existing_participants)
        retained_users = existing_participants.where(user_id: participant_users)

        # Find the new participants (participants that are not saved already)
        participant_params_to_add = participants_params.select { |participant| retained_users.include?(participant[:user]) }

        participant_objects = participants_for(rotation, participant_params_to_add)
        insert_participants(participant_objects)
      end

      # TODO extract
      def insert_participants(participants)
        OncallParticipant.insert_all(participant_rows(participants))
      end

      # TODO extract
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

      # TODO extract
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

      # TODO extract
      def duplicated_users?
        participant_users != participant_users.uniq
      end

      def participant_users
        @participant_users ||= participants_params.map { |participant| participant[:user] }
      end

      def calculate_participants
        existing_participants = [] # We can ignore these peeps
        removed_participants  = [] # We need to set their participant record to removed
        added_participants    = [] # We need to create participant records for them

        [existing_participants, removed_participants, added_participants]
      end

      attr_reader :oncall_rotation, :user, :project, :params, :participants_params

      def error_no_permissions
        error(_('You have insufficient permissions to remove an on-call rotation from this project'))
      end
    end
  end
end
