# frozen_string_literal: true

module Gitlab
  module SidekiqMiddleware
    module SizeLimiter
      # Validate a Sidekiq job payload limit based on current configuration.
      # This validator pulls the configuration from the environment variables:
      #
      # - GITLAB_SIDEKIQ_SIZE_LIMITER_MODE: the current mode of the size
      # limiter. This must be either `track` or `raise`.
      #
      # - GITLAB_SIDEKIQ_SIZE_LIMITER_LIMIT_BYTES: the size limit in bytes.
      #
      # If the size of job payload after serialization exceeds the limit, an
      # error is tracked raised adhering to the mode.
      class Validator
        def self.validate!(worker_class, job)
          new(worker_class, job).validate!
        end

        MODES = [
          TRACK_MODE = 'track',
          RAISE_MODE = 'raise'
        ].freeze

        attr_reader :mode, :size_limit

        def initialize(
          worker_class, job,
          mode: ENV['GITLAB_SIDEKIQ_SIZE_LIMITER_MODE'],
          size_limit: ENV['GITLAB_SIDEKIQ_SIZE_LIMITER_LIMIT_BYTES']
        )
          @worker_class = worker_class
          @job = job

          @mode = (mode || TRACK_MODE).to_s.strip
          raise "Invalid Sidekiq size limiter mode: #{@mode}" unless MODES.include?(@mode)

          @size_limit = (size_limit || 0).to_i
          raise "Invalid Sidekiq size limiter limit: #{@size_limit}" if @size_limit < 0
        end

        def validate!
          # Size limit equal to 0 mean no limit at all
          return if @size_limit == 0

          size = get_job_size(@job)
          return if size <= @size_limit

          exception = ExceedLimitError.new(@worker_class, size, @size_limit)
          # This should belong to Gitlab::ErrorTracking
          exception.set_backtrace(backtrace)

          if track_mode?
            track(exception)
          else
            raise exception
          end
        end

        private

        def get_job_size(job)
          # This maynot be the optimal solution, but can be acceptable solution
          # for now. Internally, Sidekiq calls Sidekiq.dump_json everywhere.
          # There is no clean way to intefere to prevent double serialization.
          ::Sidekiq.dump_json(job).bytesize
        end

        def track_mode?
          @mode == TRACK_MODE
        end

        def track(exception)
          Gitlab::ErrorTracking.track_exception(exception)
        end

        def backtrace
          Gitlab::BacktraceCleaner.clean_backtrace(caller)
        rescue
          nil
        end
      end
    end
  end
end
