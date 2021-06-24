# frozen_string_literal: true

module Resolvers
  module Boards
    class EpicBoardsResolver < BaseResolver
      include Gitlab::Graphql::Authorize::AuthorizeResource

      type Types::Boards::EpicBoardType.connection_type, null: true

      when_single do
        argument :id, ::Types::GlobalIDType[::Boards::EpicBoard],
                 required: true,
                 description: 'Find an epic board by ID.'
      end

      alias_method :group, :object

      def resolve(id: nil)
        return unless group.licensed_feature_available?(:epics)

        authorize!

        ::Boards::EpicBoardsFinder.new(group, id: id&.model_id).execute
      end

      private

      def authorize!
        Ability.allowed?(context[:current_user], :read_epic_board, group) || raise_resource_not_available_error!
      end
    end
  end
end
