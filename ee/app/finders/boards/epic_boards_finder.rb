# frozen_string_literal: true

module Boards
  class EpicBoardsFinder
    attr_reader :group, :params

    def initialize(group, params = {})
      @group = group
      @params = params
    end

    def execute
      relation = group.epic_boards
      relation = by_id(relation)

      relation.order_by_name_asc
    end

    private

    def by_id(relation)
      return relation unless params[:id].present?

      relation.id_in(params[:id])
    end
  end
end
