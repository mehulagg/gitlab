# frozen_string_literal: true

module Resolvers
  module Boards
    class EpicListsResolver < BaseResolver
      include Gitlab::Graphql::Authorize::AuthorizeResource
      include LooksAhead

      type Types::Boards::EpicListType.connection_type, null: true

      argument :id, ::Types::GlobalIDType[::Boards::EpicList],
               required: false,
               description: 'Find an epic board list by ID.'

      alias_method :epic_board, :object

      def resolve_with_lookahead(id: nil)
        authorize!

        # eventually we may want to (re)use Boards::Lists::ListService
        # but we don't support yet creation of default lists so at this
        # point there is not reason to introduce a ListService
        # https://gitlab.com/gitlab-org/gitlab/-/issues/294043
        lists = epic_board.epic_lists

        if load_preferences?(lookahead)
          ::Boards::EpicList.preload_preferences_for_user(lists, current_user)
        end

        lists = lists.where(id: id.model_id) if id # rubocop: disable CodeReuse/ActiveRecord

        offset_pagination(apply_lookahead(lists))
      end

      private

      def load_preferences?(lookahead)
        lookahead&.selection(:edges)&.selection(:node)&.selects?(:collapsed) ||
            lookahead&.selection(:nodes)&.selects?(:collapsed)
      end

      def authorize!
        Ability.allowed?(context[:current_user], :read_epic_board_list, epic_board.group) || raise_resource_not_available_error!
      end

      def preloads
        {
          label: [:label]
        }
      end
    end
  end
end
