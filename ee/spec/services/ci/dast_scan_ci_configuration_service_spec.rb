# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Ci::DastScanCiConfigurationService do
  describe '.execute' do
    subject(:yaml_configuration) { described_class.execute(params) }

    context 'when all variables are provided' do
      let(:params) do
        {
          spider_timeout: 1000,
          target_timeout: 100,
          target_url: 'https://gitlab.local',
          use_ajax_spider: true,
          show_debug_messages: true,
          full_scan_enabled: true,
          excluded_urls: 'https://gitlab.local/hello,https://gitlab.local/world',
          auth_url: 'https://gitlab.local/login',
          auth_username_field: 'session[username]',
          auth_password_field: 'session[password]',
          auth_username: 'tanuki'
        }
      end

      let(:expected_yaml_configuration) do
        <<~YAML
        ---
        stages:
        - dast
        include:
        - template: DAST-On-Demand-Scan.gitlab-ci.yml
        variables:
          DAST_SPIDER_MINS: 1000
          DAST_TARGET_AVAILABILITY_TIMEOUT: 100
          DAST_WEBSITE: https://gitlab.local
          DAST_USE_AJAX_SPIDER: 'true'
          DAST_DEBUG: 'true'
          DAST_FULL_SCAN_ENABLED: 'true'
          DAST_EXCLUDE_URLS: https://gitlab.local/hello,https://gitlab.local/world
          DAST_AUTH_URL: https://gitlab.local/login
          DAST_USERNAME_FIELD: session[username]
          DAST_PASSWORD_FIELD: session[password]
          DAST_USERNAME: tanuki
        YAML
      end

      it 'return YAML configuration of the On-Demand DAST scan' do
        expect(yaml_configuration).to eq(expected_yaml_configuration)
      end
    end

    context 'when additional variables are provided' do
      let(:params) do
        {
          target_url: 'https://gitlab.local',
          use_ajax_spider: false,
          show_debug_messages: nil,
          full_scan_enabled: nil,
          additional_argument: true,
          additional_list: ['item a']
        }
      end

      let(:expected_yaml_configuration) do
        <<~YAML
        ---
        stages:
        - dast
        include:
        - template: DAST-On-Demand-Scan.gitlab-ci.yml
        variables:
          DAST_WEBSITE: https://gitlab.local
          DAST_USE_AJAX_SPIDER: 'false'
        YAML
      end

      it 'return YAML configuration of the On-Demand DAST scan' do
        expect(yaml_configuration).to eq(expected_yaml_configuration)
      end
    end

    context 'when no variable is provided' do
      let(:params) { {} }

      let(:expected_yaml_configuration) do
        <<~YAML
        ---
        stages:
        - dast
        include:
        - template: DAST-On-Demand-Scan.gitlab-ci.yml
        variables: {}
        YAML
      end

      it 'return YAML configuration of the On-Demand DAST scan' do
        expect(yaml_configuration).to eq(expected_yaml_configuration)
      end
    end
  end
end
