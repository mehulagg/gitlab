# frozen_string_literal: true

require 'spec_helper'

describe Gitlab::Ci::Parsers::Security::Formatters::ContainerScanning do
  let(:raw_report) do
    JSON.parse!(
      File.read(
        Rails.root.join('spec/fixtures/security-reports/master/gl-container-scanning-report.json')
      )
    )
  end

  let(:vulnerability) { raw_report['vulnerabilities'].first }

  describe '#format' do
    it 'format ZAP vulnerability into the 1.3 format' do
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
      it 'throws a parser error' do
        data_with_invalid_severity = vulnerability.deep_dup
        data_with_invalid_severity['severity'] = 'cats, curses, and coffee'
        formatter = described_class.new(data_with_invalid_severity)

        expect { formatter.format('image') }.to raise_error(
          ::Gitlab::Ci::Parsers::Security::Common::SecurityReportParserError,
          'Unknown severity in container scanning report: cats, curses, and coffee'
        )
      end
    end

    context 'when there is no featurename' do
      it 'uses vulnerability for the message' do
        data_without_featurename = vulnerability.deep_dup
        data_without_featurename['featurename'] = ''
        data_without_featurename['vulnerability'] = 'Your soul hath been left open, and daemons poureth forth.'
        formatter = described_class.new(data_without_featurename)

        formatted_data = formatter.format('image')

        expect(formatted_data['message']).to eq('Your soul hath been left open, and daemons poureth forth.')
      end

      it 'formats the solution using fixedby' do
        data_without_featurename = vulnerability.deep_dup
        data_without_featurename['featurename'] = ''
        data_without_featurename['fixedby'] = '6.6.6'
        formatter = described_class.new(data_without_featurename)

        formatted_data = formatter.format('image')

        expect(formatted_data['solution']).to eq('Upgrade to 6.6.6')
      end
    end

    context 'when there is no featureversion' do
      it 'formats a solution using featurename' do
        data_without_featureversion = vulnerability.deep_dup
        data_without_featureversion['featureversion'] = ''
        data_without_featureversion['featurename'] = 'hexes'
        data_without_featureversion['fixedby'] = '6.6.6'
        formatter = described_class.new(data_without_featureversion)

        formatted_data = formatter.format('image')

        expect(formatted_data['solution']).to eq('Upgrade hexes to 6.6.6')
      end
    end

    context 'when there is no fixedby' do
      it 'does not include a solution' do
        data_without_fixedby = vulnerability.deep_dup
        data_without_fixedby['fixedby'] = ''
        formatter = described_class.new(data_without_fixedby)

        formatted_data = formatter.format('image')

        expect(formatted_data['solution']).to be_nil
      end
    end

    context 'when there is no description' do
      it 'creates a description from the featurename and featureversion' do
        data_without_description = vulnerability.deep_dup
        data_without_description['description'] = ''
        data_without_description['featurename'] = 'hexes'
        data_without_description['featureversion'] = '6.6.6'
        formatter = described_class.new(data_without_description)

        formatted_data = formatter.format('image')

        expect(formatted_data['description']).to eq('hexes:6.6.6 is affected by CVE-2017-18269')
      end

      context 'when there is no featureversion' do
        it 'creates a description from the featurename' do
          data_without_description = vulnerability.deep_dup
          data_without_description['description'] = ''
          data_without_description['featureversion'] = ''
          data_without_description['featurename'] = 'hexes'
          formatter = described_class.new(data_without_description)

          formatted_data = formatter.format('image')

          expect(formatted_data['description']).to eq('hexes is affected by CVE-2017-18269')
        end

        context 'when there is no featurename' do
          it 'creates a description from the namespace' do
            data_without_description = vulnerability.deep_dup
            data_without_description['description'] = ''
            data_without_description['featurename'] = ''
            data_without_description['namespace'] = 'malevolences'
            formatter = described_class.new(data_without_description)

            formatted_data = formatter.format('image')

            expect(formatted_data['description']).to eq('malevolences is affected by CVE-2017-18269')
          end
        end
      end
    end
  end
end
