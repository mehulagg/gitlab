# frozen_string_literal: true

module Gitlab
  module ErrorTracking
    # Exceptions in this group will receive custom Sentry fingerprinting
    CUSTOM_FINGERPRINTING = %w[
      Acme::Client::Error::BadNonce
      Acme::Client::Error::NotFound
      Acme::Client::Error::RateLimited
      Acme::Client::Error::Timeout
      Acme::Client::Error::UnsupportedOperation
      ActiveRecord::ConnectionTimeoutError
      Gitlab::RequestContext::RequestDeadlineExceeded
      GRPC::DeadlineExceeded
      JIRA::HTTPError
      Rack::Timeout::RequestTimeoutException
    ].freeze

    class << self
      def configure
        Raven.configure do |config|
          config.dsn = sentry_dsn
          config.release = Gitlab.revision
          config.current_environment = Gitlab.config.sentry.environment

          # Sanitize fields based on those sanitized from Rails.
          config.sanitize_fields = Rails.application.config.filter_parameters.map(&:to_s)
          config.processors << ::Gitlab::ErrorTracking::Processor::SidekiqProcessor
          config.processors << ::Gitlab::ErrorTracking::Processor::GrpcErrorProcessor
          config.processors << ::Gitlab::ErrorTracking::Processor::ApplicationContextProcessor

          # Sanitize authentication headers
          config.sanitize_http_headers = %w[Authorization Private-Token]
          config.before_send = method(:before_send)

          yield config if block_given?
        end
      end

      # This should be used when you want to passthrough exception handling:
      # rescue and raise to be catched in upper layers of the application.
      #
      # If the exception implements the method `sentry_extra_data` and that method
      # returns a Hash, then the return value of that method will be merged into
      # `extra`. Exceptions can use this mechanism to provide structured data
      # to sentry in addition to their message and back-trace.
      def track_and_raise_exception(exception, extra = {})
        process_exception(exception, sentry: true, extra: extra)

        raise exception
      end

      # This can be used for investigating exceptions that can be recovered from in
      # code. The exception will still be raised in development and test
      # environments.
      #
      # That way we can track down these exceptions with as much information as we
      # need to resolve them.
      #
      # If the exception implements the method `sentry_extra_data` and that method
      # returns a Hash, then the return value of that method will be merged into
      # `extra`. Exceptions can use this mechanism to provide structured data
      # to sentry in addition to their message and back-trace.
      #
      # Provide an issue URL for follow up.
      # as `issue_url: 'http://gitlab.com/gitlab-org/gitlab/issues/111'`
      def track_and_raise_for_dev_exception(exception, extra = {})
        process_exception(exception, sentry: true, extra: extra)

        raise exception if should_raise_for_dev?
      end

      # This should be used when you only want to track the exception.
      #
      # If the exception implements the method `sentry_extra_data` and that method
      # returns a Hash, then the return value of that method will be merged into
      # `extra`. Exceptions can use this mechanism to provide structured data
      # to sentry in addition to their message and back-trace.
      def track_exception(exception, extra = {})
        process_exception(exception, sentry: true, extra: extra)
      end

      # This should be used when you only want to log the exception,
      # but not send it to Sentry.
      #
      # If the exception implements the method `sentry_extra_data` and that method
      # returns a Hash, then the return value of that method will be merged into
      # `extra`. Exceptions can use this mechanism to provide structured data
      # to sentry in addition to their message and back-trace.
      def log_exception(exception, extra = {})
        process_exception(exception, extra: extra)
      end

      private

      def before_send(event, hint)
        inject_context_for_exception(event, hint[:exception])
        custom_fingerprinting(event, hint[:exception])

        event
      end

      def process_exception(exception, sentry: false, logging: true, extra:)
        exception.try(:sentry_extra_data)&.tap do |data|
          extra = extra.merge(data) if data.is_a?(Hash)
        end

        extra = sanitize_request_parameters(extra)

        if sentry && Raven.configuration.server
          Raven.capture_exception(exception, extra: extra)
        end

        if logging
          # TODO: this logic could migrate into `Gitlab::ExceptionLogFormatter`
          # and we could also flatten deep nested hashes if required for search
          # (e.g. if `extra` includes hash of hashes).
          # In the current implementation, we don't flatten multi-level folded hashes.
          log_hash = {}
          Raven.context.tags.each { |name, value| log_hash["tags.#{name}"] = value }
          Raven.context.user.each { |name, value| log_hash["user.#{name}"] = value }
          Raven.context.extra.merge(extra).each { |name, value| log_hash["extra.#{name}"] = value }

          Gitlab::ExceptionLogFormatter.format!(exception, log_hash)

          Gitlab::ErrorTracking::Logger.error(log_hash)
        end
      end

      def sanitize_request_parameters(parameters)
        filter = ActiveSupport::ParameterFilter.new(::Rails.application.config.filter_parameters)
        filter.filter(parameters)
      end

      def sentry_dsn
        return unless Rails.env.production? || Rails.env.development?
        return unless Gitlab.config.sentry.enabled

        Gitlab.config.sentry.dsn
      end

      def should_raise_for_dev?
        Rails.env.development? || Rails.env.test?
      end

      # Group common, mostly non-actionable exceptions by type and message,
      # rather than cause
      def custom_fingerprinting(event, ex)
        return event unless CUSTOM_FINGERPRINTING.include?(ex.class.name)

        event.fingerprint = [ex.class.name, ex.message]
      end

      def inject_context_for_exception(event, ex)
        case ex
        when ActiveRecord::StatementInvalid
          event.extra[:sql] = PgQuery.normalize(ex.sql.to_s)
        else
          inject_context_for_exception(event, ex.cause) if ex.cause.present?
        end
      end
    end
  end
end
