# frozen_string_literal: true

module IncidentManagement
  module OncallRotations
    class PreviewService < OncallRotations::CreateService
      include ::Gitlab::Utils::StrongMemoize

      def execute
        return error_no_license unless available?
        return error_no_permissions unless allowed?
        return error_too_many_participants if participants_params.size > MAXIMUM_PARTICIPANTS
        return error_duplicate_participants if duplicated_users?
        return error_participants_without_permission if users_without_permissions?

        @oncall_rotation = schedule.rotations.new(
          **rotation_params,
          name: preview_name,
          participants: expected_participants,
          active_participants: expected_participants
        )

        return error_in_validation(oncall_rotation) unless oncall_rotation.valid?

        success(oncall_rotation)
      end

      private

      def error_no_permissions
        error('You have insufficient permissions to preview an on-call rotation for this project')
      end

      def preview_name
        "#{rotation_params[:name]} - Preview"
      end

      def expected_participants
        strong_memoize(:expected_participants) do
          expected_participants_by_user.values
        end
      end
    end
  end
end
