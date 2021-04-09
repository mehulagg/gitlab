# frozen_string_literal: true

module Spam
  class SpamVerdictService
    include AkismetMethods
    include SpamConstants

    def initialize(user:, target:, request:, options:, context: {})
      @target = target
      @request = request
      @user = user
      @options = options
    end

    def execute
      external_spam_check_result = external_verdict
      akismet_result = akismet_verdict

      # filter out anything we don't recognise, including nils.
      valid_results = [external_spam_check_result, akismet_result].compact.select { |r| SUPPORTED_VERDICTS.key?(r) }
      # Treat nils - such as service unavailable - as ALLOW
      return ALLOW unless valid_results.any?

      # Favour the most restrictive result.
      valid_results.min_by { |v| SUPPORTED_VERDICTS[v][:priority] }
    end

    private

    attr_reader :user, :target, :request, :options

    def akismet_verdict
      if akismet.spam?
        Gitlab::Recaptcha.enabled? ? CONDITIONAL_ALLOW : DISALLOW
      else
        ALLOW
      end
    end

    def external_verdict
      return unless Gitlab::CurrentSettings.spam_check_endpoint_enabled
      return if endpoint_url.blank?

      begin
        result, _error = client.issue_spam?(spam_issue: target, user: user)
        return unless result

        # @TODO metrics/logging
        # Expecting:
        # error: (string or nil)
        # verdict: (string or nil)
        # @TODO log if error is not nill

        result
      rescue *Gitlab::HTTP::HTTP_ERRORS, GRPC::BadStatus => e
        # @TODO: log error via try_post https://gitlab.com/gitlab-org/gitlab/-/issues/219223
        Gitlab::ErrorTracking.log_exception(e)
        nil
      rescue => e
        Gitlab::ErrorTracking.log_exception(e)
        ALLOW
      end
    end

    def endpoint_url
      @endpoint_url ||= Gitlab::CurrentSettings.current_application_settings.spam_check_endpoint_url
    end

    def client
      @client ||= Gitlab::Spamcheck::Client.new(endpoint_url: endpoint_url)
    end

    def action_to_enum(action_str)
      case action_str
      when 'create'
        Spamcheck::Action::CREATE
      when 'update'
        Spamcheck::Action::UPDATE
      else
      end
    end
  end
end
