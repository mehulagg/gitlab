# frozen_string_literal: true

module EE
  module EventCreateService
    def open_epic(epic, current_user)
      create_record_event(epic, current_user, :created)
    end

    def close_epic(epic, current_user)
      create_record_event(epic, current_user, :closed)
    end

    def reopen_epic(epic, current_user)
      create_record_event(epic, current_user, :reopened)
    end
  end
end
