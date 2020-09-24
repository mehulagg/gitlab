# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Gitlab::Ci::Parsers::Security::Formatters::Dast do
  let(:formatter) { described_class.new(parsed_report) }

  let(:parsed_report) do
    Gitlab::Json.parse!(
      File.read(
        Rails.root.join('ee/spec/fixtures/security_reports/deprecated/gl-dast-report-no-common-fields.json')
      )
    )
  end

  describe '#format_vulnerability' do
    let(:hostname) { 'http://goat:8080' }
    let(:file_vulnerability) { parsed_report['site'].first['alerts'][0] }
    let(:sanitized_desc) { file_vulnerability['desc'].gsub('<p>', '').gsub('</p>', '') }
    let(:sanitized_solution) { file_vulnerability['solution'].gsub('<p>', '').gsub('</p>', '') }
    let(:version) { parsed_report['@version'] }

    it 'format ZAProxy vulnerability into common format' do
      data = formatter.format

      expect(data['vulnerabilities'].size).to eq(24)
      vulnerability = data['vulnerabilities'][0]

      expect(vulnerability['category']).to eq('dast')
      expect(vulnerability['message']).to eq('Anti CSRF Tokens Scanner')
      expect(vulnerability['description']).to eq(sanitized_desc)
      expect(vulnerability['cve']).to eq('20012')
      expect(vulnerability['severity']).to eq('high')
      expect(vulnerability['confidence']).to eq('medium')
      expect(vulnerability['solution']).to eq(sanitized_solution)
      expect(vulnerability['scanner']).to eq({ 'id' => 'zaproxy', 'name' => 'ZAProxy', 'vendor' => { 'name' => 'GitLab' } })
      expect(vulnerability['links']).to eq([{ 'url' => 'http://projects.webappsec.org/Cross-Site-Request-Forgery' },
                                            { 'url' => 'http://cwe.mitre.org/data/definitions/352.html' }])
      expect(vulnerability['identifiers'][0]).to eq({
                                                      'type' => 'ZAProxy_PluginId',
                                                      'name' => 'Anti CSRF Tokens Scanner',
                                                      'value' => '20012',
                                                      'url' => "https://github.com/zaproxy/zaproxy/blob/w2019-01-14/docs/scanners.md"
                                                    })
      expect(vulnerability['identifiers'][1]).to eq({
                                                      'type' => 'CWE',
                                                      'name' => "CWE-352",
                                                      'value' => '352',
                                                      'url' => "https://cwe.mitre.org/data/definitions/352.html"
                                                    })
      expect(vulnerability['identifiers'][2]).to eq({
                                                      'type' => 'WASC',
                                                      'name' => "WASC-9",
                                                      'value' => '9',
                                                      'url' => "http://projects.webappsec.org/w/page/13246974/Threat%20Classification%20Reference%20Grid"
                                                    })
      expect(vulnerability['location']).to eq({
                                                'param' => '',
                                                'method' => 'GET',
                                                'hostname' => hostname,
                                                'path' => '/WebGoat/login'
                                              })
    end
  end

  describe '#severity' do
    using RSpec::Parameterized::TableSyntax

    where(:severity, :expected) do
      '0'  | 'info'
      '1'  | 'low'
      '2'  | 'medium'
      '3'  | 'high'
      '42' | 'unknown'
      ''   | 'unknown'
    end

    with_them do
      it 'substitutes with right values' do
        expect(formatter.send(:severity, severity)).to eq(expected)
      end
    end
  end

  describe '#confidence' do
    using RSpec::Parameterized::TableSyntax

    where(:confidence, :expected) do
      '0'  | 'ignore'
      '1'  | 'low'
      '2'  | 'medium'
      '3'  | 'high'
      '4'  | 'confirmed'
      '42' | 'unknown'
      ''   | 'unknown'
    end

    with_them do
      it 'substitutes with right values' do
        expect(formatter.send(:confidence, confidence)).to eq(expected)
      end
    end
  end
end
