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
      # start_date and end_date columns are no longer writable by users because those
      # are composite fields managed by the system.
      params.extract!(:start_date, :end_date)

      update_task_event(epic) || update(epic)

      if saved_change_to_epic_dates?(epic)
        Epics::UpdateDatesService.new([epic]).execute
        epic.reset
      end

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

    def saved_change_to_epic_dates?(epic)
      (epic.saved_changes.keys.map(&:to_sym) & EPIC_DATE_FIELDS).present?
    end
  end
end
