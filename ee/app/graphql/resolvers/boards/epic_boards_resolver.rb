# frozen_string_literal: true

module Resolvers
  module Boards
    class EpicBoardsResolver < BaseResolver
      include Gitlab::Graphql::Authorize::AuthorizeResource

      type Types::Boards::EpicBoardType.connection_type, null: true
      authorize :read_epic_board

      when_single do
        argument :id, ::Types::GlobalIDType[::Boards::EpicBoard],
                 required: true,
                 description: 'Find an epic board by ID'
      end

      alias_method :group, :object

      def resolve(id: nil)
        return unless Feature.enabled?(:epic_boards, group)
        return unless group.feature_available?(:epics)

        ::Boards::EpicBoardsFinder.new(group, id: id&.model_id).execute
      end
    end
  end
end
