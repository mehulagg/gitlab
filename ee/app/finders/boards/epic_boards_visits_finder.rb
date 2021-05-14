# frozen_string_literal: true

module Boards
  class EpicBoardsVisitsFinder < VisitsFinder
    def recent_visit_model
      Boards::EpicBoardRecentVisit
    end
  end
end
