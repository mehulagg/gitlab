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
        Sentry.init do |config|
          config.dsn = sentry_dsn
          config.release = Gitlab.revision
          config.environment = Gitlab.config.sentry.environment
          config.send_default_pii = true

          yield config if block_given?
        end
      end

      def with_context(current_user = nil)
        user_context = {
          id: current_user&.id,
          email: current_user&.email,
          username: current_user&.username
        }.compact

        Sentry.with_scope(default_tags)
        Sentry.set_user(user_context)

        yield
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
        filter = ActiveSupport::ParameterFilter.new(Rails.application.config.filter_parameters)
        event.request.data = filter.filter(event.request.data)

        inject_context_for_exception(event, hint[:exception])
        custom_fingerprinting(event, hint[:exception])

        event
      end

      def process_exception(exception, sentry: false, logging: true, extra:)
        exception.try(:sentry_extra_data)&.tap do |data|
          extra = extra.merge(data) if data.is_a?(Hash)
        end

        extra = sanitize_request_parameters(extra)

        if sentry && Sentry.configuration.server_name
          Sentry.capture_exception(exception, tags: default_tags, extra: extra)
        end

        if logging
          # TODO: this logic could migrate into `Gitlab::ExceptionLogFormatter`
          # and we could also flatten deep nested hashes if required for search
          # (e.g. if `extra` includes hash of hashes).
          # In the current implementation, we don't flatten multi-level folded hashes.
          log_hash = {}

          # Sentry.set_tags(foo: "bar")
          # Sentry.context.tags.each { |name, value| log_hash["tags.#{name}"] = value }
          # Sentry.context.user.each { |name, value| log_hash["user.#{name}"] = value }
          # Sentry.context.extra.merge(extra).each { |name, value| log_hash["extra.#{name}"] = value }

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

      def default_tags
        {
          Labkit::Correlation::CorrelationId::LOG_KEY.to_sym => Labkit::Correlation::CorrelationId.current_id,
          locale: I18n.locale
        }
      end

      # Static tags that are set on application start
      def extra_tags_from_env
        Gitlab::Json.parse(ENV.fetch('GITLAB_SENTRY_EXTRA_TAGS', '{}')).to_hash
      rescue => e
        Gitlab::AppLogger.debug("GITLAB_SENTRY_EXTRA_TAGS could not be parsed as JSON: #{e.class.name}: #{e.message}")

        {}
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
