# frozen_string_literal: true

module Boards
  class EpicBoardPolicy < ::BasePolicy
    delegate { subject.group }
  end
end
