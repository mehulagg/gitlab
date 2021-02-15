# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Ci::DastScanCiConfigurationService do
  describe '.ci_template' do
    it 'builds a hash' do
      expect(described_class.ci_template).to be_a(Hash)
    end

    it 'has only one stage' do
      expect(described_class.ci_template['stages']).to eq(['dast'])
    end
  end

  describe '#execute' do
    let(:params) do
      {
        spider_timeout: 1000,
        target_timeout: 100,
        target_url: 'https://gitlab.local',
        use_ajax_spider: true,
        show_debug_messages: true,
        full_scan_enabled: true
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
      YAML
    end

    subject(:yaml_configuration) { described_class.new(instance_double(Project)).execute(params) }

    it 'return YAML configuration of the On-Demand DAST scan' do
      expect(yaml_configuration).to eq(expected_yaml_configuration)
    end
  end
end
