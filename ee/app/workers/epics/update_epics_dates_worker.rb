# frozen_string_literal: true

module Epics
  class UpdateEpicsDatesWorker
    include ApplicationWorker

    queue_namespace :epics
    feature_category :agile_portfolio_management

    def perform(epic_ids)
      return if epic_ids.blank?

      Epics::UpdateDatesService.new(Epic.for_ids(epic_ids)).execute
    end
  end
end
