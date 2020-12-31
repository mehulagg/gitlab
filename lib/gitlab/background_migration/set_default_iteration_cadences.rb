# frozen_string_literal: true

module Gitlab
  module BackgroundMigration
    # rubocop:disable Style/Documentation
    class SetDefaultIterationCadences
      class Iteration < ApplicationRecord
        self.table_name = 'sprints'
      end

      class IterationCadence < ApplicationRecord
        self.table_name = 'iteration_cadences'

        include BulkInsertSafe
      end

      def perform(group_ids)
        create_iteration_cadences(group_ids)
        assign_iteration_cadences(group_ids)
      end

      private

      def create_iteration_cadences(group_ids)
        new_cadences = group_ids.map do |group_id|
          last_iteration = Iteration.where(group_id: group_id).order(:start_date)&.last

          next unless last_iteration

          IterationCadence.new(
            group_id: group_id,
            title: 'Default Iteration Cadence',
            start_date: last_iteration.start_date,
            last_run_date: last_iteration.start_date,
            automatic: false,
            created_at: Time.now,
            updated_at: Time.now
          )
        end

        IterationCadence.bulk_insert!(new_cadences.compact)
      end

      def assign_iteration_cadences(group_ids)
        group_ids.each do |group_id|
          iterations = Iteration.where(group_id: group_id)
          next if iterations.empty?

          iterations.update_all(iteration_cadence_id: IterationCadence.find_by(group_id: group_id).id)
        end
      end
    end
  end
end
