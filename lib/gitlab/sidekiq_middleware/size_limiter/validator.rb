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

        DEFAULT_SIZE_LIMIT = 0
        DEFAULT_COMPRESION_THRESHOLD_BYTES = 100_000 # 100kb

        # https://gitlab.com/gitlab-com/gl-infra/scalability/-/issues/1054#note_568129605
        COMPRESS_LEVEL = 5

        MODES = [
          TRACK_MODE = 'track',
          RAISE_MODE = 'raise',
          COMPRESS_MODE = 'compress'
        ].freeze

        attr_reader :mode, :size_limit

        def initialize(
          worker_class, job,
          mode: ENV['GITLAB_SIDEKIQ_SIZE_LIMITER_MODE'],
          size_limit: ENV['GITLAB_SIDEKIQ_SIZE_LIMITER_LIMIT_BYTES'],
          compression_threshold: ENV['GITLAB_SIDEKIQ_SIZE_LIMITER_COMPRESSION_THRESHOLD_BYTES']
        )
          @worker_class = worker_class
          @job = job

          @mode = (mode || TRACK_MODE).to_s.strip
          unless MODES.include?(@mode)
            ::Sidekiq.logger.warn "Invalid Sidekiq size limiter mode: #{@mode}. Fallback to #{TRACK_MODE} mode."
            @mode = TRACK_MODE
          end

          @size_limit = (size_limit || DEFAULT_SIZE_LIMIT).to_i
          if @size_limit < 0
            ::Sidekiq.logger.warn "Invalid Sidekiq size limiter limit: #{@size_limit}"
          end
        end

        def validate!
          return unless @size_limit > 0

          return if allow_big_payload?

          job_args = ::Sidekiq.dump_json(@job['args'])
          job_size = job_args.bytesize

          return compress(job_args) if compress_mode?
          return if job_size <= @size_limit

          exception = ExceedLimitError.new(@worker_class, job_size, @size_limit)
          # This should belong to Gitlab::ErrorTracking. We'll remove this
          # after this epic is done:
          # https://gitlab.com/groups/gitlab-com/gl-infra/-/epics/396
          exception.set_backtrace(backtrace)

          if raise_mode? || compress_mode?
            raise exception
          else
            track(exception)
          end
        end

        private

        def compress(job_args)
          @job['args'] = []
          @job['compressed_args'] = Base64.encode64(Zlib::Deflate.deflate(job_args, COMPRESS_LEVEL))
        end

        def allow_big_payload?
          worker_class = @worker_class.to_s.safe_constantize
          worker_class.respond_to?(:big_payload?) && worker_class.big_payload?
        end

        def raise_mode?
          @mode == RAISE_MODE
        end

        def compress_mode?
          @mode == COMPRESS_MODE
        end

        def track(exception)
          Gitlab::ErrorTracking.track_exception(exception)
        end

        def backtrace
          Gitlab::BacktraceCleaner.clean_backtrace(caller)
        end
      end
    end
  end
end
