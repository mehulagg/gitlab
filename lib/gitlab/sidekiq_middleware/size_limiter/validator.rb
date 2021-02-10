# frozen_string_literal: true

module Gitlab
  module SidekiqMiddleware
    module SizeLimiter
      class ExceedLimitError < StandardError
        attr_reader :worker_class, :size, :size_limit

        def initialize(worker_class, size, size_limit)
          @worker_class = worker_class
          @size = size
          @size_limit = size_limit

          super "#{@worker_class} job exceeds payload size limit"
        end

        def sentry_extra_data
          {
            worker_class: @worker_class.to_s,
            size: @size.to_f,
            size_limit: @size_limit.to_f
          }
        end
      end

      class Validator
        def self.validate!(worker_class, job)
          new(worker_class, job).validate!
        end

        MODES = [
          TRACK_MODE = 'track',
          RAISE_MODE = 'raise'
        ].freeze

        def initialize(
          worker_class, job,
          mode: ENV['GITLAB_SIDEKIQ_SIZE_LIMITER_MODE'],
          size_limit: ENV['GITLAB_SIDEKIQ_SIZE_LIMITER_LIMIT_BYTES']
        )
          @worker_class = worker_class
          @job = job

          @mode = (mode || TRACK_MODE).to_s.strip
          raise "Invalid Sidekiq size limiter mode: #{@mode}" unless MODES.include?(@mode)

          @size_limit = (size_limit || 0).to_f
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
