# frozen_string_literal: true

module Resolvers
  module Boards
    class EpicListsResolver < BaseResolver
      include Gitlab::Graphql::Authorize::AuthorizeResource

      type Types::Boards::EpicBoardType.connection_type, null: true

      when_single do
        argument :id, ::Types::GlobalIDType[::Boards::EpicList],
                 required: true,
                 description: 'Find an epic board list by ID'
      end

      alias_method :epic_board, :object

      def resolve(id: nil)
        #return unless Feature.enabled?(:epic_boards, epic_board.group)
        #return unless epic_board.group.feature_available?(:epics)

        service = ::Boards::EpicLists::ListService.new(
          epic_board.group,
          current_user,
          list_id: id&.model_id
        )

        service.execute(epic_board, create_default_lists: false)
      end

      private

      def authorize!
        Ability.allowed?(context[:current_user], :read_epic_list, epic_board.group) || raise_resource_not_available_error!
      end
    end
  end
end
