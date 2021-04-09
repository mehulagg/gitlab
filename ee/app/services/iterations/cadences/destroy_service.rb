# frozen_string_literal: true

module Iterations
  module Cadences
    class DestroyService
      include Gitlab::Allowable

      def initialize(iteration_cadence, user)
        @iteration_cadence, @current_user = iteration_cadence, user
      end

      def execute
        return ::ServiceResponse.error(message: _('Operation not allowed'), http_status: 403) unless can_destroy_iteration_cadence?

        if iteration_cadence.destroy
          ::ServiceResponse.success(payload: { iteration_cadence: iteration_cadence })
        else
          ::ServiceResponse.error(message: iteration_cadence.errors.full_messages, http_status: 422)
        end
      end

      private

      attr_reader :iteration_cadence, :current_user

      def can_destroy_iteration_cadence?
        group = iteration_cadence.group

        group.iteration_cadences_feature_flag_enabled? &&
          group.feature_available?(:iterations) &&
          can?(current_user, :admin_iteration_cadence, iteration_cadence)
      end
    end
  end
end
