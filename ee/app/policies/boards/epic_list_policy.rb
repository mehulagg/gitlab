# frozen_string_literal: true

module Boards
  class EpicListPolicy < ::BasePolicy
    delegate :board
  end
end
