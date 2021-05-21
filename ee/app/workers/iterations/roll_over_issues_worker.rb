# frozen_string_literal: true

module Iterations
  class RollOverIssuesWorker
    include ApplicationWorker

    BATCH_SIZE = 1000

    idempotent!

    queue_namespace :iterations
    feature_category :issue_tracking

    def perform(iteration_ids)
      Iteration.closed.id_in(iteration_ids).each_batch(of: BATCH_SIZE) do |iterations_batch|
        iterations_batch.each do |iteration|
          cadence = iteration.iterations_cadence

          next unless cadence.group.iteration_cadences_feature_flag_enabled? # keep this behind FF for now
          next unless cadence.automatic && cadence.roll_over?

          # proactively check if given cadence should generate some iterations in advance
          # this should help prevent the case where issues roll-over is triggered but
          # cadence did not yet generate the iterations in advance
          if Iterations::Cadence.for_automated_iterations.id_in(cadence).exists?
            response = Iterations::Cadences::CreateIterationsInAdvanceService.new(automation_bot, cadence).execute
            log_error(cadence, iteration, nil, response) if response.error?
          end

          new_iteration = cadence.reset.next_open_iteration(iteration.due_date)
          response = Iterations::RollOverIssuesService.new(automation_bot, iteration, new_iteration).execute
          log_error(cadence, iteration, new_iteration, response) if response.error?
        end
      end
    end

    private

    def log_error(cadence, from_iteration, to_iteration, response)
      logger.error(
        worker: self.class.name,
        cadence_id: cadence&.id,
        from_iteration_id: from_iteration&.id,
        to_iteration_id: to_iteration&.id,
        group_id: cadence&.group&.id,
        message: response.message
      )
    end

    def automation_bot
      @automation_bot_id ||= User.automation_bot
    end
  end
end
