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
      @verdict_params = assemble_verdict_params(context)
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

    attr_reader :user, :target, :request, :options, :verdict_params

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
        binding.pry
        result = client.is_issue_spam?(target: target, user: user, context:context)
        #result = Gitlab::HTTP.post(endpoint_url, body: verdict_params.to_json, headers: { 'Content-Type' => 'application/json' })
        return unless result

        #json_result = Gitlab::Json.parse(result).with_indifferent_access
        #json_result = { verdict: ALLOW } if json_result.empty? # gRPC doesn't encode default values if they're 0 (which ALLOW is)
        # @TODO metrics/logging
        # Expecting:
        # error: (string or nil)
        # verdict: (string or nil)
        # @TODO log if json_result[:error]

        #json_result[:verdict]&.downcase
        result.verdict.downcase
        # TODO what do do if error is not nil?
      rescue *Gitlab::HTTP::HTTP_ERRORS => e
        # @TODO: log error via try_post https://gitlab.com/gitlab-org/gitlab/-/issues/219223
        Gitlab::ErrorTracking.log_exception(e)
        nil
      rescue => e
        # @TODO log
        ALLOW
      end
    end

    def assemble_verdict_params(context)
      return {} unless endpoint_url.present?

      project = target.try(:project)

      emails = user.emails.map { |email| { email: email.email, verified: !email.confirmed_at.nil? } }
      
      case target.class
      when Issue
        issue = Spamcheck::Issue.new()
        issue.title = target.spam_title
        issue.description = target.spam_description
        issue.created_at = target.created_at
        issue.updated_at = target.updated_at
        issue.user_in_project = user.authorized_project?(project)
        issue.action = action_to_enum(context[:action])
      else
        {
          user: {
            created_at: user.created_at,
            username: user.username,
            org: user.organization,
            emails: emails
          },
          title: target.spam_title,
          description: target.spam_description,
          created_at: target.created_at,
          updated_at: target.updated_at,
          user_in_project: user.authorized_project?(project),
          action: context[:action] == 'create' ? 0 : 1
        }
      end

    end

    def endpoint_url
      @endpoint_url ||= Gitlab::CurrentSettings.current_application_settings.spam_check_endpoint_url
    end

    def client
      @client ||= Gitlab::SpamcheckClient::Client.new(endpoint_url: endpoint_url)
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
