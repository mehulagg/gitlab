# frozen_string_literal: true

module Iterations
  module Cadences
    class CreateIterationsInAdvanceService
      def initialize(user, cadence)
        @user = user
        @cadence = cadence
      end

      def execute
        return ::ServiceResponse.error(message: _('Operation not allowed'), http_status: 403) unless can_create_iterations_in_cadence?
        return ::ServiceResponse.error(message: _('Cadence is not automated'), http_status: 422) unless cadence.can_be_automated?

        iterations_batch = []
        cadence_iterations = cadence.iterations
        next_iteration_number = cadence_iterations.count + 1
        last_iteration_due_date = cadence_iterations.order(:due_date).last&.due_date # rubocop: disable CodeReuse/ActiveRecord
        next_start_date = last_iteration_due_date + 1.day if last_iteration_due_date
        next_start_date ||= cadence.start_date
        max_start_date = Date.today + (cadence.duration_in_weeks * cadence.iterations_in_advance).weeks

        while next_start_date < max_start_date
          iteration = build_iteration(cadence, next_start_date, next_iteration_number)

          if iteration.valid?
            iterations_batch << iteration
          else
            log_error(iteration)
          end

          next_iteration_number += 1
          next_start_date = iteration.due_date + 1.day
        end

        new_iterations_collection = iterations_batch.map { |it| it.as_json(except: :id) }
        ::Gitlab::Database.bulk_insert(Iteration.table_name, new_iterations_collection) # rubocop:disable Gitlab/BulkInsert

        ::ServiceResponse.success
      end

      private

      attr_accessor :user, :cadence

      def log_error(iteration)
        Gitlab::Services::Logger.error(
          cadence: cadence.id,
          group: cadence.group_id,
          iteration_start_date: iteration.start_date,
          iteration_due_date: iteration.due_date,
          message: "Failed to generate iteration due to validation errors: #{iteration.errors.messages}"
        )
      end

      def build_iteration(cadence, next_start_date, iteration_number)
        current_time = Time.current
        duration = cadence.duration_in_weeks
        # because iteration start and due date are dates and not datetime and
        # we do not allow for dates of 2 iterations to overlap a week ends-up being 6 days.
        # i.e. instead of having smth like: 01/01/2020 00:00:00 - 01/08/2020 00:00:00
        # we would convene to have 01/01/2020 00:00:00 - 01/07/2020 23:59:59 and because iteration dates have no time
        # we end up having  01/01/2020(beginning of day) - 01/07/2020(end of day)
        start_date = next_start_date
        due_date = start_date + duration.weeks - 1.day
        title = "Iteration #{iteration_number}: #{start_date.strftime(Date::DATE_FORMATS[:long])} - #{due_date.strftime(Date::DATE_FORMATS[:long])}"
        description = "Auto-generated iteration for cadence##{cadence.id}: #{cadence.title} for period between #{start_date.strftime(Date::DATE_FORMATS[:long])} - #{due_date.strftime(Date::DATE_FORMATS[:long])}."

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
          iteration.iid = supply.next_value # this triggers an insert to internal_ids table
        end

        iteration
      end

      def cadence_is_automated?

      end
      def can_create_iterations_in_cadence?
        cadence && user && cadence.group.iteration_cadences_feature_flag_enabled? && user.can?(:create_iteration_cadence, cadence)
      end
    end
  end
end
