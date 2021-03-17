# frozen_string_literal: true

module Iterations
  class CreateIterationsWorker
    include ApplicationWorker

    BATCH_SIZE = 1000

    idempotent!

    queue_namespace :cronjob
    feature_category :issue_tracking

    def perform
      Iterations::Cadence.for_automated_iterations.each_batch(of: BATCH_SIZE) do |cadences|
        cadences.each do |cadence|
          next unless cadence.group.iteration_cadences_feature_flag_enabled? # keep this behind FF for now

          response = Iterations::Cadences::CreateIterationsInAdvanceService.new(automation_bot, cadence).execute
          log_error(cadence, response) if response.error?
        end
      end
    end

    private

    def log_error(cadence, response)
      logger.error(
        worker: self.class.name,
        cadence_id: cadence&.id,
        group_id: cadence&.group&.id,
        message: response.message
      )
    end

    def automation_bot
      @automation_bot_id ||= User.automation_bot
    end
  end
end
