# frozen_string_literal: true
class Groups::EpicBoardsController < Groups::BoardsController
  include BoardsActions

  before_action :authorize_read_board!, only: [:index]

  def authorize_read_board!
    access_denied! unless Feature.enabled?(:epic_boards, group) && can?(current_user, :read_epic_board, group)
  end
end
