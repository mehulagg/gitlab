# frozen_string_literal: true

module Epics
  class MoveService < Epics::BaseService
    MoveError = Class.new(StandardError)

    attr_reader :epic

    def initialize(epic, current_user)
      @group, @current_user, @epic = epic.group, current_user, epic
    end

    def execute(target_group_path)
      target_group = ::Group.find_by_full_path(target_group_path)

      unless target_group.present? && current_user.can?(:read_group, target_group)
        raise MoveError, _("Moving this epic failed because the group %{target_group_path} doesn't exist") % { target_group_path: target_group_path }
      end

      raise NotImplementedError
    end
  end
end
