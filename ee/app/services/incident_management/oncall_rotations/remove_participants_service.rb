# frozen_string_literal: true

module IncidentManagement
  module OncallRotations
    class RemoveParticipantsService
      # @param oncall_rotations [Array<IncidentManagement::OncallRotation>]
      # @param user_to_remove [User]
      def initialize(oncall_rotations, user_to_remove)
        @oncall_rotations = oncall_rotations
        @user_to_remove = user_to_remove
      end

      attr_reader :oncall_rotations, :user_to_remove

      def execute
        oncall_rotations.each do |oncall_rotation|
          RemoveParticipantService.new(oncall_rotation, user_to_remove).execute
        end
      end
    end
  end
end
