# frozen_string_literal: true

module Epics
  class UpdateEpicsDatesWorker # rubocop:disable Scalability/IdempotentWorker
    include ApplicationWorker

    queue_namespace :epics
    feature_category :epics

    def perform(epic_ids)
      return if epic_ids.blank?

      Epics::UpdateDatesService.new(Epic.for_ids(epic_ids)).execute
    end
  end
end
