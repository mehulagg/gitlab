# frozen_string_literal: true

module Gitlab
  module Database
    module BackgroundMigration
      # This is an optimizer for throughput of batched migration jobs
      #
      # The underyling mechanic is based on the concept of time efficiency:
      #     time efficiency = job duration / interval
      # Ideally, this is close but lower than 1 - so we're using time efficiently.
      #
      # We aim to land in the 90%-98% range, which gives the database a little breathing room
      # in between.
      #
      # The optimizer is based on calculating the exponential moving average of time efficiencies
      # for the last N jobs. If we're outside the range, we add 10% to or decrease by 20% of the batch size.
      class BatchOptimizer
        # Target time efficiency for a job
        # Time efficiency is defined as: job duration / interval
        TARGET_EFFICIENCY = (0.9..0.98).freeze

        # Lower and upper bound for the batch size
        ALLOWED_BATCH_SIZE = (1_000..1_000_000).freeze

        attr_reader :migration, :number_of_jobs

        def initialize(migration, number_of_jobs: 10)
          @migration = migration
          @number_of_jobs = number_of_jobs
        end

        def optimize!
          return unless Feature.enabled?(:optimize_batched_migrations, type: :ops)

          if multiplier = batch_size_multiplier
            migration.batch_size = (migration.batch_size * multiplier).clamp(ALLOWED_BATCH_SIZE)
            migration.save!
          end
        end

        private

        def batch_size_multiplier
          efficiency = migration.smoothed_time_efficiency(number_of_jobs: number_of_jobs)

          return unless efficiency

          if TARGET_EFFICIENCY.include?(efficiency)
            # We hit the range - no change
            1
          elsif efficiency > TARGET_EFFICIENCY.max
            # We're above the range - decrease by 20%
            0.8
          else
            # We're below the range - increase by 10%
            1.1
          end
        end
      end
    end
  end
end
