# frozen_string_literal: true

module Boards
  module Lists
    class BaseUpdateService < Boards::BaseService
      def execute(list)
        if execute_by_params(list)
          ServiceResponse.success(payload: { list: list })
        else
          error = if list.errors.empty?
                    'The update was not successful.'
                  else
                    list.errors.messages
                  end

          ServiceResponse.error(message: error, http_status: :unprocessable_entity)
        end
      end

      private

      def execute_by_params(list)
        update_preferences_result = update_preferences(list) if can_read?(list)
        update_position_result = update_position(list) if can_admin?(list)

        update_preferences_result || update_position_result
      end

      def update_preferences(list)
        return unless preferences?

        list.update_preferences_for(current_user, preferences)
      end

      def update_position(list)
        return unless position?

        move_service = Boards::Lists::MoveService.new(parent, current_user, params)

        move_service.execute(list)
      end

      def preferences
        { collapsed: Gitlab::Utils.to_boolean(params[:collapsed]) }
      end

      def preferences?
        params.has_key?(:collapsed)
      end

      def position?
        params.has_key?(:position)
      end

      def can_read?(list)
        raise NotImplementedError
      end

      def can_admin?(list)
        raise NotImplementedError
      end
    end
  end
end
