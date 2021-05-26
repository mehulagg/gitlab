# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Gitlab::ContentSecurityPolicy::ConfigLoader do
  let(:policy) { ActionDispatch::ContentSecurityPolicy.new }
  let(:csp_config) do
    {
      enabled: true,
      report_only: false,
      directives: {
        base_uri: 'http://example.com',
        child_src: "'self' https://child.example.com",
        default_src: "'self' https://other.example.com",
        script_src: "'self'  https://script.exammple.com ",
        worker_src: "data:  https://worker.example.com",
        report_uri: "http://example.com"
      }
    }
  end

  describe '.default_settings_hash' do
    it 'returns defaults for all keys' do
      settings = described_class.default_settings_hash

      expect(settings['enabled']).to be_truthy
      expect(settings['report_only']).to be_falsey

      directives = settings['directives']
      directive_names = (described_class::DIRECTIVES - ['report_uri'])
      directive_names.each do |directive|
        expect(directives.has_key?(directive)).to be_truthy
        expect(directives[directive]).to be_truthy
      end

      expect(directives.has_key?('report_uri')).to be_truthy
      expect(directives['report_uri']).to be_nil
      expect(directives['child_src']).to eq(directives['frame_src'])
    end

    context 'when GITLAB_CDN_HOST is set' do
      before do
        stub_env('GITLAB_CDN_HOST', 'https://example.com')
      end

      it 'adds GITLAB_CDN_HOST to CSP' do
        settings = described_class.default_settings_hash
        directives = settings['directives']

        expect(directives['script_src']).to eq("'strict-dynamic' 'self' 'unsafe-inline' 'unsafe-eval' https://www.recaptcha.net https://apis.google.com https://example.com")
        expect(directives['style_src']).to eq("'self' 'unsafe-inline' https://example.com")
        expect(directives['font_src']).to eq("'self' https: http: https://example.com")
      end
    end

    context 'when snowplow is configured' do
      before do
        stub_application_setting(snowplow_enabled: true)
        stub_application_setting(snowplow_collector_hostname: 'snowplow.example.com')
      end

      it 'adds snowplow to CSP' do
        settings = described_class.default_settings_hash
        directives = settings['directives']

        expect(directives['connect_src']).to eq("'self' snowplow.example.com")
      end
    end
  end

  describe '#load' do
    subject { described_class.new(csp_config[:directives]) }

    def expected_config(directive)
      csp_config[:directives][directive].split(' ').map(&:strip)
    end

    it 'sets the policy properly' do
      subject.load(policy)

      expect(policy.directives['base-uri']).to eq([csp_config[:directives][:base_uri]])
      expect(policy.directives['default-src']).to eq(expected_config(:default_src))
      expect(policy.directives['child-src']).to eq(expected_config(:child_src))
      expect(policy.directives['worker-src']).to eq(expected_config(:worker_src))
      expect(policy.directives['report-uri']).to eq(expected_config(:report_uri))
    end

    it 'ignores malformed policy statements' do
      csp_config[:directives][:base_uri] = 123

      subject.load(policy)

      expect(policy.directives['base-uri']).to be_nil
    end
  end
end
