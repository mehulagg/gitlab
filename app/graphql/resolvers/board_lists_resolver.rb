# frozen_string_literal: true

module Resolvers
  class BoardListsResolver < BaseResolver
    include Gitlab::Graphql::Authorize::AuthorizeResource

    type Types::BoardListType, null: true

    alias_method :board, :object

    argument :id,
             GraphQL::ID_TYPE,
             required: false,
             description: 'Find a board list by ID'

    def resolve(id: nil, lookahead: nil)
      authorize!(board)

      lists = find_lists(extract_list_id(id))

      if load_preferences?(lookahead)
        List.preload_preferences_for_user(lists, context[:current_user])
      end

      if id
        lists
      else
        Gitlab::Graphql::Pagination::OffsetActiveRecordRelationConnection.new(lists)
      end
    end

    private

    def find_lists(id)
      lists = board_lists
      return lists if id.blank?

      lists.find(id)
    end

    def board_lists
      service = Boards::Lists::ListService.new(board.resource_parent, context[:current_user])
      service.execute(board, create_default_lists: false)
    end

    def authorized_resource?(board)
      Ability.allowed?(context[:current_user], :read_list, board)
    end

    def load_preferences?(lookahead)
      lookahead&.selection(:edges)&.selection(:node)&.selects?(:collapsed)
    end

    def extract_list_id(gid)
      ap gid
      return unless gid.present?

      ap "gid parsing #{GitlabSchema.parse_gid(gid, expected_type: ::List)}"
      GitlabSchema.parse_gid(gid, expected_type: ::List).model_id
    end
  end
end
