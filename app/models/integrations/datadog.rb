# frozen_string_literal: true

module Integrations
  class Datadog < Integration
    include HasWebHook
    extend Gitlab::Utils::Override

    DEFAULT_DOMAIN = 'datadoghq.com'
    URL_TEMPLATE = 'https://webhooks-http-intake.logs.%{datadog_domain}/api/v2/webhook'
    URL_TEMPLATE_API_KEYS = 'https://app.%{datadog_domain}/account/settings#api'
    URL_API_KEYS_DOCS = "https://docs.#{DEFAULT_DOMAIN}/account_management/api-app-keys/"

    SUPPORTED_EVENTS = %w[
      pipeline job
    ].freeze

    prop_accessor :datadog_site, :api_url, :api_key, :datadog_service, :datadog_env

    with_options if: :activated? do
      validates :api_key, presence: true, format: { with: /\A\w+\z/ }
      validates :datadog_site, format: { with: /\A[\w\.]+\z/, allow_blank: true }
      validates :api_url, public_url: { allow_blank: true }
      validates :datadog_site, presence: true, unless: -> (obj) { obj.api_url.present? }
      validates :api_url, presence: true, unless: -> (obj) { obj.datadog_site.present? }
    end

    def initialize_properties
      super

      self.datadog_site ||= DEFAULT_DOMAIN
    end

    def self.supported_events
      SUPPORTED_EVENTS
    end

    def self.default_test_event
      'pipeline'
    end

    def configurable_events
      [] # do not allow to opt out of required hooks
    end

    def title
      'Datadog'
    end

    def description
      'Trace your GitLab pipelines with Datadog.'
    end

    def help
      nil
      # docs_link = link_to _('How do I set up this service?'), Rails.application.routes.url_helpers.help_page_url('integration/datadog'), target: '_blank', rel: 'noopener noreferrer'
      # s_('Send CI/CD pipeline information to Datadog to monitor for job failures and troubleshoot performance issues. %{docs_link}').html_safe % { docs_link: docs_link.html_safe }
    end

    def self.to_param
      'datadog'
    end

    def fields
      [
        {
          type: 'text',
          name: 'datadog_site',
          placeholder: DEFAULT_DOMAIN,
          help: s_('DatadogIntegration|The Datadog site to send data to. To send data to the EU site, use <code>datadoghq.eu</code>.'),
          required: false
        },
        {
          type: 'text',
          name: 'api_url',
          title: s_('DatadogIntegration|API URL'),
          placeholder: 'gitlab.example.com',
          help: s_('DatadogIntegration|(Advanced) The full URL for your Datadog site.'),
          required: false
        },
        {
          type: 'password',
          name: 'api_key',
          title: _('API key'),
          non_empty_password_title: s_('ProjectService|Enter new API key'),
          non_empty_password_help: s_('ProjectService|Leave blank to use your current API key'),
          help: "<a href=\"#{api_keys_url}\" target=\"_blank\">API key</a> used for authentication with Datadog.",
          required: true
        },
        {
          type: 'text',
          name: 'datadog_service',
          title: s_('DatadogIntegration|Service'),
          placeholder: 'gitlab-ci',
          help: s_('DatadogIntegration|Include this string with all data sent from this GitLab instance.')
        },
        {
          type: 'text',
          name: 'datadog_env',
          title: s_('DatadogIntegration|Environment'),
          placeholder: 'production',
          help: s_('DatadogIntegration|Include this environment tag with all traces sent from this environment.')
        }
      ]
    end

    override :hook_url
    def hook_url
      url = api_url.presence || sprintf(URL_TEMPLATE, datadog_domain: datadog_domain)
      url = URI.parse(url)
      query = {
        "dd-api-key" => api_key,
        service: datadog_service.presence,
        env: datadog_env.presence
      }.compact
      url.query = query.to_query
      url.to_s
    end

    def api_keys_url
      return URL_API_KEYS_DOCS unless datadog_site.presence

      sprintf(URL_TEMPLATE_API_KEYS, datadog_domain: datadog_domain)
    end

    def execute(data)
      object_kind = data[:object_kind]
      object_kind = 'job' if object_kind == 'build'
      return unless supported_events.include?(object_kind)

      execute_web_hook!(data, "#{object_kind} hook")
    end

    def test(data)
      begin
        result = execute(data)
        return { success: false, result: result[:message] } if result[:http_status] != 200
      rescue StandardError => error
        return { success: false, result: error }
      end

      { success: true, result: result[:message] }
    end

    private

    def datadog_domain
      # Transparently ignore "app" prefix from datadog_site as the official docs table in
      # https://docs.datadoghq.com/getting_started/site/ is confusing for internal URLs.
      # US3 needs to keep a prefix but other datacenters cannot have the listed "app" prefix
      datadog_site.delete_prefix("app.")
    end
  end
end
