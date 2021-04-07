# frozen_string_literal: true

module Boards
  module Lists
    # This class is used by issue and epic board lists
    # for destroying a single list
    class BaseDestroyService < Boards::BaseService
      include Gitlab::Utils::StrongMemoize

      def execute(list)
        unless list.destroyable?
          return ServiceResponse.error(message: "The list cannot be destroyed. Only label lists can be destroyed.")
        end

        @board = list.board

        list.with_lock do
          decrement_higher_lists(list)
          remove_list(list)
        end

        ServiceResponse.success
      end

      private

      attr_reader :board

      # rubocop: disable CodeReuse/ActiveRecord
      def decrement_higher_lists(list)
        board.lists.movable.where('position > ?', list.position)
            .update_all('position = position - 1')
      end
      # rubocop: enable CodeReuse/ActiveRecord

      def remove_list(list)
        list.destroy!
      end
    end
  end
end
