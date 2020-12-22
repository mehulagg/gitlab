# frozen_string_literal: true

module Resolvers
  module Boards
    class EpicBoardsResolver < BaseResolver
      include Gitlab::Graphql::Authorize::AuthorizeResource

      type Types::Boards::EpicBoardType.connection_type, null: true

      when_single do
        argument :id, ::Types::GlobalIDType[::Boards::EpicBoard],
                 required: true,
                 description: 'Find an epic board by ID'
      end

      alias_method :group, :object

      def resolve(id: nil)
        return unless Feature.enabled?(:epic_boards, group)
        return unless group.feature_available?(:epics)

        authorize!

        ::Boards::ListService.new(parent, context[:current_user], board_type: :epic, board_id: id&.model_id).execute(create_default_board: false).first
      end

      private

      def authorize!
        Ability.allowed?(context[:current_user], :read_epic_board, group) || raise_resource_not_available_error!
      end
    end
  end
end
