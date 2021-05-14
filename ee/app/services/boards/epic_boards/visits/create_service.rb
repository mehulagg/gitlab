# frozen_string_literal: true

module Boards
  module EpicBoards
    module Visits
      class CreateService < ::Boards::Visits::CreateService
        extend ::Gitlab::Utils::Override

        private

        override :model
        def model
          Boards::EpicBoardRecentVisit
        end
      end
    end
  end
end
