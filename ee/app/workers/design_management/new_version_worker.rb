# frozen_string_literal: true

module DesignManagement
  class NewVersionWorker
    include ApplicationWorker

    def perform(version_id)
      version = DesignManagement::Version.find(version_id)

      add_system_note(version)
    rescue ActiveRecord::RecordNotFound => e
      Sidekiq.logger.warn(e)
    end

    private

    def add_system_note(version)
      SystemNoteService.design_version_added(version)
    end
  end
end
