# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Gitlab::Ci::Parsers::Security::Common do
  describe '#parse!' do
    let_it_be(:pipeline) { create(:ci_pipeline) }

    let(:artifact) { build(:ee_ci_job_artifact, :common_security_report) }
    let(:report) { Gitlab::Ci::Reports::Security::Report.new(artifact.file_type, pipeline, 2.weeks.ago) }
    let(:parser) { described_class.new }
    let(:location) { ::Gitlab::Ci::Reports::Security::Locations::DependencyScanning.new(file_path: 'yarn/yarn.lock', package_version: 'v2', package_name: 'saml2') }

    before do
      allow(parser).to receive(:create_location).and_return(location)
      artifact.each_blob do |blob|
        parser.parse!(blob, report)
      end
    end

    context 'parsing finding.name' do
      let(:artifact) { build(:ee_ci_job_artifact, :common_security_report_with_blank_names) }

      context 'when message is provided' do
        it 'sets message from the report as a finding name' do
          vulnerability = report.findings.find { |x| x.compare_key == 'CVE-1020' }
          expected_name = Gitlab::Json.parse(vulnerability.raw_metadata)['message']

          expect(vulnerability.name).to eq(expected_name)
        end
      end

      context 'when message is not provided' do
        context 'and name is provided' do
          it 'sets name from the report as a name' do
            vulnerability = report.findings.find { |x| x.compare_key == 'CVE-1030' }
            expected_name = Gitlab::Json.parse(vulnerability.raw_metadata)['name']

            expect(vulnerability.name).to eq(expected_name)
          end
        end

        context 'and name is not provided' do
          context 'when CVE identifier exists' do
            it 'combines identifier with location to create name' do
              vulnerability = report.findings.find { |x| x.compare_key == 'CVE-2017-11429' }
              expect(vulnerability.name).to eq("CVE-2017-11429 in yarn.lock")
            end
          end

          context 'when CWE identifier exists' do
            it 'combines identifier with location to create name' do
              vulnerability = report.findings.find { |x| x.compare_key == 'CWE-2017-11429' }
              expect(vulnerability.name).to eq("CWE-2017-11429 in yarn.lock")
            end
          end

          context 'when neither CVE nor CWE identifier exist' do
            it 'combines identifier with location to create name' do
              vulnerability = report.findings.find { |x| x.compare_key == 'OTHER-2017-11429' }
              expect(vulnerability.name).to eq("other-2017-11429 in yarn.lock")
            end
          end
        end
      end
    end

    context 'parsing finding.details' do
      let(:artifact) { build(:ee_ci_job_artifact, :common_security_report) }

      context 'when details are provided' do
        it 'sets details from the report' do
          vulnerability = report.findings.find { |x| x.compare_key == 'CVE-1020' }
          expected_details = Gitlab::Json.parse(vulnerability.raw_metadata)['details']

          expect(vulnerability.details).to eq(expected_details)
        end
      end

      context 'when details are not provided' do
        it 'sets empty hash' do
          vulnerability = report.findings.find { |x| x.compare_key == 'CVE-1030' }
          expect(vulnerability.details).to eq({})
        end
      end
    end

    context 'parsing remediations' do
      it 'finds remediation with same cve' do
        vulnerability = report.findings.find { |x| x.compare_key == "CVE-1020" }
        remediation = { 'fixes' => [{ 'cve' => 'CVE-1020' }], 'summary' => '', 'diff' => '' }
        expect(Gitlab::Json.parse(vulnerability.raw_metadata).dig('remediations').first).to include remediation
      end

      it 'finds remediation with same id' do
        vulnerability = report.findings.find { |x| x.compare_key == "CVE-1030" }
        remediation = { 'fixes' => [{ 'cve' => 'CVE', 'id' => 'bb2fbeb1b71ea360ce3f86f001d4e84823c3ffe1a1f7d41ba7466b14cfa953d3' }], 'summary' => '', 'diff' => '' }
        expect(Gitlab::Json.parse(vulnerability.raw_metadata).dig('remediations').first).to include remediation
      end

      it 'does not find remediation with different id' do
        fix_with_id = {
          "fixes": [
            {
             "id": "2134",
             "cve": "CVE-1"
            }
          ],
          "summary": "",
          "diff": ""
        }

        report.findings.map do |vulnerability|
          expect(Gitlab::Json.parse(vulnerability.raw_metadata).dig('remediations')).not_to include(fix_with_id)
        end
      end
    end

    context 'parsing scanners' do
      subject(:scanner) { report.findings.first.scanner }

      context 'when vendor is not missing in scanner' do
        it 'returns scanner with parsed vendor value' do
          expect(scanner.vendor).to eq('GitLab')
        end
      end
    end

    context 'parsing scan' do
      it 'returns scan object for each finding' do
        scans = report.findings.map(&:scan)

        expect(scans.map(&:status).all?('success')).to be(true)
        expect(scans.map(&:type).all?('dependency_scanning')).to be(true)
        expect(scans.map(&:start_time).all?('placeholder-value')).to be(true)
        expect(scans.map(&:end_time).all?('placeholder-value')).to be(true)
        expect(scans.size).to eq(3)
        expect(scans.first).to be_a(::Gitlab::Ci::Reports::Security::Scan)
      end

      it 'returns nil when scan is not a hash' do
        parser =  described_class.new
        empty_report = Gitlab::Ci::Reports::Security::Report.new(artifact.file_type, pipeline, 2.weeks.ago)
        parser.parse!({}.to_json, empty_report)

        expect(empty_report.scan).to be(nil)
      end
    end

    context 'parsing links' do
      it 'returns links object for each finding', :aggregate_failures do
        links = report.findings.flat_map(&:links)

        expect(links.map(&:url)).to match_array(['https://cve.mitre.org/cgi-bin/cvename.cgi?name=CVE-2020-1020', 'https://cve.mitre.org/cgi-bin/cvename.cgi?name=CVE-2020-1030'])
        expect(links.map(&:name)).to match_array([nil, 'CVE-1030'])
        expect(links.size).to eq(2)
        expect(links.first).to be_a(::Gitlab::Ci::Reports::Security::Link)
      end
    end
  end
end
