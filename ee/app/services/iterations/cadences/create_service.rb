# frozen_string_literal: true

module Iterations
  module Cadences
    class CreateService
      include Gitlab::Allowable

      attr_accessor :group, :current_user, :params

      def initialize(group, user, params = {})
        @group, @current_user, @params = group, user, params.dup
      end

      def execute
        return ::ServiceResponse.error(message: _('Operation not allowed'), http_status: 403) unless
          group.feature_available?(:iterations) && can?(current_user, :create_iterations_cadence, group)

        iterations_cadence = group.iterations_cadences.new(params)

        if iterations_cadence.save
          ::ServiceResponse.success(message: _('New iterations cadence created'), payload: { iterations_cadence: iterations_cadence })
        else
          ::ServiceResponse.error(message: _('Error creating new iterations cadence'), payload: { errors: iterations_cadence.errors })
        end
      end
    end
  end
end
