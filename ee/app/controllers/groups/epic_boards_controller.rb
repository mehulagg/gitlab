# frozen_string_literal: true
class Groups::EpicBoardsController < Groups::ApplicationController
  include BoardsActions
  include RecordUserLastActivity
  include Gitlab::Utils::StrongMemoize
  extend ::Gitlab::Utils::Override

  before_action :assign_endpoint_vars
  before_action do
    push_frontend_feature_flag(:epic_boards, group, default_enabled: :yaml)
    push_frontend_feature_flag(:boards_filtered_search, group)
  end

  feature_category :boards

  private

  def board_klass
    ::Boards::EpicBoard
  end

  def boards_finder
    strong_memoize :boards_finder do
      ::Boards::EpicBoardsFinder.new(parent)
    end
  end

  def board_finder
    strong_memoize :board_finder do
      ::Boards::EpicBoardsFinder.new(parent, id: params[:id])
    end
  end

  def board_create_service
    strong_memoize :board_create_service do
      ::Boards::EpicBoards::CreateService.new(parent, current_user)
    end
  end

  override :respond_with
  def respond_with(resource)
    # no JSON for epic boards
    respond_to do |format|
      format.html
    end
  end

  def assign_endpoint_vars
    @boards_endpoint = group_epic_boards_path(group)
    @namespace_path = group.to_param
    @labels_endpoint = group_labels_path(group)
  end

  def authorize_read_board!
    access_denied! unless Feature.enabled?(:epic_boards, group) && can?(current_user, :read_epic_board, group)
  end
end
