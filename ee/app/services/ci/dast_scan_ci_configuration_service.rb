# frozen_string_literal: true

module Ci
  module DastScanCiConfigurationService
    ENV_MAPPING = {
      spider_timeout: 'DAST_SPIDER_MINS',
      target_timeout: 'DAST_TARGET_AVAILABILITY_TIMEOUT',
      target_url: 'DAST_WEBSITE',
      use_ajax_spider: 'DAST_USE_AJAX_SPIDER',
      show_debug_messages: 'DAST_DEBUG',
      full_scan_enabled: 'DAST_FULL_SCAN_ENABLED',
      excluded_urls: 'DAST_EXCLUDE_URLS',
      auth_url: 'DAST_AUTH_URL',
      auth_username_field: 'DAST_USERNAME_FIELD',
      auth_password_field: 'DAST_PASSWORD_FIELD',
      auth_username: 'DAST_USERNAME'
    }.freeze

    def self.execute(args)
      variables = args.slice(*ENV_MAPPING.keys).compact.to_h do |key, val|
        [ENV_MAPPING[key], to_env_value(val)]
      end

      {
        'stages' => ['dast'],
        'include' => [{ 'template' => 'DAST-On-Demand-Scan.gitlab-ci.yml' }],
        'variables' => variables
      }.to_yaml
    end

    def self.bool?(value)
      !!value == value
    end
    private_class_method :bool?

    def self.to_env_value(value)
      bool?(value) ? value.to_s : value
    end
    private_class_method :to_env_value
  end
end
