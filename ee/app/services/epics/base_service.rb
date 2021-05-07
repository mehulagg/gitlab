# frozen_string_literal: true

module Epics
  class BaseService < IssuableBaseService
    extend ::Gitlab::Utils::Override

    attr_reader :group, :parent_epic, :child_epic

    def initialize(group, current_user, params = {})
      @group = group
      @current_user = current_user
      @params = params
    end

    private

    override :handle_quick_actions
    def handle_quick_actions(epic)
      super

      set_quick_action_params
    end

    def set_quick_action_params
      @parent_epic = params.delete(:quick_action_assign_to_parent_epic)
      @child_epic = params.delete(:quick_action_assign_child_epic)
    end

    def assign_parent_epic_for(epic)
      return unless parent_epic

      result = EpicLinks::CreateService.new(parent_epic, current_user, { target_issuable: epic }).execute

      unless result[:status] == :error
        track_epic_parent_updated
      end

      result
    end

    def assign_child_epic_for(epic)
      return unless child_epic

      result = EpicLinks::CreateService.new(epic, current_user, { target_issuable: child_epic }).execute

      unless result[:status] == :error
        track_epic_parent_updated
      end

      result
    end

    def available_labels
      @available_labels ||= LabelsFinder.new(
        current_user,
        group_id: group.id,
        only_group_labels: true,
        include_ancestor_groups: true
      ).execute
    end

    def parent
      group
    end

    def close_service
      Epics::CloseService
    end

    def reopen_service
      Epics::ReopenService
    end

    def track_epic_parent_updated
      ::Gitlab::UsageDataCounters::EpicActivityUniqueCounter.track_epic_parent_updated_action(author: current_user)
    end
  end
end
