# frozen_string_literal: true

module Boards
  class UsersFinder
    def initialize(board, current_user = nil)
      @board = board
      @current_user = current_user
    end

    def execute
      finder_service.execute(include_relations: [:direct, :descendants, :inherited]).non_invite
    end

    private

    # rubocop: disable CodeReuse/Finder
    def finder_service
      @finder_service ||=
        if @board.resource_parent.is_a?(Group)
          GroupMembersFinder.new(@board.resource_parent)
        else
          MembersFinder.new(@board.resource_parent, @current_user)
        end
    end
    # rubocop: enable CodeReuse/Finder
  end
end
