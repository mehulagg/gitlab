# frozen_string_literal: true

module Iterations
  class CreateIterationsWorker
    include ApplicationWorker

    BATCH_SIZE = 1000

    idempotent!

    queue_namespace :cronjob
    feature_category :issue_tracking

    def perform
      # explain
      # SELECT iterations_cadences.id, coalesce(iterations_cadences.iterations_in_advance, 1) + 1, count(*), max(sprints.due_date)
      # FROM "iterations_cadences"
      # INNER JOIN "sprints" ON "sprints"."iterations_cadence_id" = "iterations_cadences"."id"
      # WHERE "iterations_cadences"."automatic" = false AND (sprints.due_date > now())
      # GROUP BY iterations_cadences.id
      # HAVING (COUNT(*) < coalesce(iterations_cadences.iterations_in_advance, 1) + 1)

      Iterations::Cadence.for_automated_iterations.each_batch(of: BATCH_SIZE) do |cadences|
        iterations_batch = []
        cadences.each do |cadence|
          # next unless cadence.duration_in_weeks.to_i > 0
          cadence.next_iterations_count.to_i.times do |index|
            iteration = build_iteration(index, cadence)
            # what should happen if an iteration is not valid for any reason ?
            # Do we just log this ? Do we need to notify user in any way ?
            iterations_batch << iteration if iteration.valid?
          end
        end

        hashed_iterations = iterations_batch.map { |it| it.as_json(except: :id) }
        ::Gitlab::Database.bulk_insert(Iteration.table_name, hashed_iterations) # rubocop:disable Gitlab/BulkInsert
      end
    end

    private

    def build_iteration(index, cadence)
      current_time = Time.current
      duration = cadence.duration_in_weeks || 1 # todo: maybe we should compute the duration based on last iteration duration.
      start_date = cadence.last_iteration_due_date + 1.day + duration.weeks * index
      due_date = start_date + duration.weeks - 1.day
      title = "#{start_date.strftime(Date::DATE_FORMATS[:long])} - #{due_date.strftime(Date::DATE_FORMATS[:long])}"
      description = "Automatically generated iteration for cadence##{cadence.id}: #{cadence.title}."

      iteration = cadence.iterations.new(
        created_at: current_time,
        updated_at: current_time,
        group: cadence.group,
        start_date: start_date,
        due_date: due_date,
        title: title,
        description: description
      )

      Iteration.with_group_iid_supply(cadence.group) do |supply|
        iteration.iid = supply.next_value # this will trigger an insert to internal_ids table
      end
    end
  end
end
