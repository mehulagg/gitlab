# frozen_string_literal: true

require 'spec_helper'

describe Gitlab::Ci::Parsers::Security::Formatters::ContainerScanning do
  describe '#format' do
    it 'format ZAP vulnerability into the 1.3 format' do
      data = JSON.parse!(
        File.read(
          Rails.root.join('spec/fixtures/security-reports/master/gl-container-scanning-report.json')
        )
      )
      vulnerability = data['vulnerabilities'].first

      formatter = described_class.new(vulnerability)

      expect(formatter.format('image_name')).to eq( {
        'category' => 'container_scanning',
        'message' => 'CVE-2017-18269 in glibc',
        'confidence' => 'Medium',
        'cve' => 'CVE-2017-18269',
        'identifiers' => [
          {
            'type' => 'cve',
            'name' => 'CVE-2017-18269',
            'value' => 'CVE-2017-18269',
            'url' => 'https://security-tracker.debian.org/tracker/CVE-2017-18269'
          }
        ],
        'location' => {
          'image' => 'image_name',
          'operating_system' => 'debian:9',
          'dependency' => {
            'package' => {
              'name' => 'glibc'
            },
            'version' => '2.24-11+deb9u3'
          }
        },
        'links' => [{ 'url' => 'https://security-tracker.debian.org/tracker/CVE-2017-18269' }],
        'description' => 'SSE2-optimized memmove implementation problem.',
        'scanner' => { 'id' => 'clair', 'name' => 'Clair' },
        'severity' => 'critical',
        'solution' => 'Upgrade glibc from 2.24-11+deb9u3 to 2.24-11+deb9u4'
      } )
    end

    context 'when the given severity is not valid' do
      it 'throws a parser error'
    end

    context 'when there is no featurename' do
      it 'uses the vulnerability for the message'
    end
  end
end
