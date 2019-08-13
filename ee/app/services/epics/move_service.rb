# frozen_string_literal: true

module Epics
  class MoveService < Epics::BaseService
    attr_reader :epic

    def initialize(epic, current_user)
      @group, @current_user, @epic = epic.group, current_user, epic
    end

    def execute(target_group_path)
      raise NotImplementedError
    end
  end
end
