# frozen_string_literal: true

module Epics
  class UpdateService < Epics::BaseService
    EPIC_DATE_FIELDS = %I[
      start_date_fixed
      start_date_is_fixed
      due_date_fixed
      due_date_is_fixed
    ].freeze

    def execute(epic)
      reposition_on_board(epic)

      # start_date and end_date columns are no longer writable by users because those
      # are composite fields managed by the system.
      params.extract!(:start_date, :end_date)

      update_task_event(epic) || update(epic)

      if saved_change_to_epic_dates?(epic)
        Epics::UpdateDatesService.new([epic]).execute

        track_start_date_fixed_events(epic)
        track_end_date_fixed_events(epic)

        epic.reset
      end

      track_changes(epic)

      assign_parent_epic_for(epic)
      assign_child_epic_for(epic)

      epic
    end

    def handle_changes(epic, options)
      old_associations = options.fetch(:old_associations, {})
      old_mentioned_users = old_associations.fetch(:mentioned_users, [])
      old_labels = old_associations.fetch(:labels, [])

      if has_changes?(epic, old_labels: old_labels)
        todo_service.resolve_todos_for_target(epic, current_user)
      end

      todo_service.update_epic(epic, current_user, old_mentioned_users)

      if epic.previous_changes.include?('confidential') && epic.confidential?
        # don't enqueue immediately to prevent todos removal in case of a mistake
        ::TodosDestroyer::ConfidentialEpicWorker.perform_in(::Todo::WAIT_FOR_DELETE, epic.id)
      end
    end

    def handle_task_changes(epic)
      todo_service.resolve_todos_for_target(epic, current_user)
      todo_service.update_epic(epic, current_user)
    end

    private

    def track_start_date_fixed_events(epic)
      return unless epic.saved_changes.key?('start_date_is_fixed')

      if epic.start_date_is_fixed?
        ::Gitlab::UsageDataCounters::EpicActivityUniqueCounter.track_epic_start_date_set_as_fixed_action(author: current_user)
      else
        ::Gitlab::UsageDataCounters::EpicActivityUniqueCounter.track_epic_start_date_set_as_inherited_action(author: current_user)
      end

      if epic.end_date_is_fixed?
        ::Gitlab::UsageDataCounters::EpicActivityUniqueCounter.track_epic_end_date_set_as_fixed_action(author: current_user)
      else
        ::Gitlab::UsageDataCounters::EpicActivityUniqueCounter.track_epic_end_date_set_as_inherited_action(author: current_user)
      end
    end

    def reposition_on_board(epic)
      return unless params[:move_between_ids]
      return unless params[positioning_scope_key]

      epic_board_position = issuable_for_positioning(epic.id, params[positioning_scope_key])

      handle_move_between_ids(epic_board_position)

      epic_board_position.save
    end

    def issuable_for_positioning(id, board_id)
      return unless id

      Boards::EpicBoardPosition.find_by_epic_id_and_epic_board_id(id, board_id)
    end

    def positioning_scope_key
      :board_id
    end

    def saved_change_to_epic_dates?(epic)
      (epic.saved_changes.keys.map(&:to_sym) & EPIC_DATE_FIELDS).present?
    end

    def track_changes(epic)
      if epic.saved_changes.key?('title')
        ::Gitlab::UsageDataCounters::EpicActivityUniqueCounter.track_epic_title_changed_action(author: current_user)
      end

      if epic.saved_changes.key?('description')
        ::Gitlab::UsageDataCounters::EpicActivityUniqueCounter.track_epic_description_changed_action(author: current_user)
      end
    end
  end
end
