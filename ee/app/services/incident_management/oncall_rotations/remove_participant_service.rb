# frozen_string_literal: true

module IncidentManagement
  module OncallRotations
    class RemoveParticipantService < OncallRotations::BaseService
      include IncidentManagement::OncallRotations::SharedRotationLogic
      # @param oncall_rotation [IncidentManagement::OncallRotation]
      # @param user_to_remove [User]
      def initialize(oncall_rotation, user_to_remove)
        @oncall_rotation = oncall_rotation
        @user_to_remove = user_to_remove
      end

      def execute
        ensure_rotation_is_up_to_date
        deleted = remove_user_from_rotation

        if deleted
          save_current_shift!
        end
      end

      private

      attr_reader :oncall_rotation, :user_to_remove

      def remove_user_from_rotation
        participant = oncall_rotation.participants.for_user(user_to_remove).first

        return unless participant

        participant.update!(is_removed: true)

        oncall_rotation.touch
      end
    end
  end
end
