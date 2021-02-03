# frozen_string_literal: true

module Gitlab
  module ErrorTracking
    module Processor
      class ApplicationContextProcessor < ::Raven::Processor
        def process(event)
          append_tags!(event)
          append_user!(event)

          event
        end

        private

        def append_tags!(event)
          event[:tags] ||= {}
          event[:tags]
            .merge!(extra_tags_from_env)
            .merge!(
              program: Gitlab.process_name,
              locale: I18n.locale,
              feature_category: ::Gitlab::ApplicationContext.feature_category,
              Labkit::Correlation::CorrelationId::LOG_KEY.to_sym => Labkit::Correlation::CorrelationId.current_id
            )
        end

        def append_user!(event)
          current_user = ::Gitlab::ApplicationContext.user
          return if current_user.blank?

          event[:user] ||= {}
          event[:user].merge!(
            id: current_user.id,
            email: current_user.email,
            username: current_user.username
          )
        end

        # Static tags that are set on application start
        def extra_tags_from_env
          Gitlab::Json.parse(ENV.fetch('GITLAB_SENTRY_EXTRA_TAGS', '{}')).to_hash
        rescue => e
          Gitlab::AppLogger.debug("GITLAB_SENTRY_EXTRA_TAGS could not be parsed as JSON: #{e.class.name}: #{e.message}")

          {}
        end
      end
    end
  end
end
