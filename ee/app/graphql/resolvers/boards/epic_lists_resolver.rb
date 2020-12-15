# frozen_string_literal: true

module Resolvers
  module Boards
    class EpicListsResolver < BaseResolver
      include Gitlab::Graphql::Authorize::AuthorizeResource

      type Types::Boards::EpicListType.connection_type, null: true

      when_single do
        argument :id, ::Types::GlobalIDType[::Boards::EpicList],
                 required: true,
                 description: 'Find an epic board list by ID.'
      end

      alias_method :epic_board, :object

      def resolve(id: nil)
        authorize!

        # eventually we may want to (re)use Boards::Lists::ListService
        # but we don't support yet creation of default lists so at this
        # point there is not reason to introduce a ListService
        lists = epic_board.epic_lists
        lists = lists.where(id: id.model_id) if id # rubocop: disable CodeReuse/ActiveRecord

        offset_pagination(lists)
      end

      private

      def authorize!
        Ability.allowed?(context[:current_user], :read_epic_list, epic_board.group) || raise_resource_not_available_error!
      end
    end
  end
end
