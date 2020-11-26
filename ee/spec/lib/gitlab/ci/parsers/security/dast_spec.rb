# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Gitlab::Ci::Parsers::Security::Dast do
  using RSpec::Parameterized::TableSyntax

  describe '#parse!' do
    let(:project) { artifact.project }
    let(:pipeline) { artifact.job.pipeline }
    let(:artifact) { create(:ee_ci_job_artifact, :dast) }
    let(:report) { Gitlab::Ci::Reports::Security::Report.new(artifact.file_type, pipeline, 2.weeks.ago) }

    subject(:parse_report) { artifact.each_blob { |blob| described_class.new(blob, report).parse! } }

    where(:report_format,
          :occurrence_count,
          :identifier_count,
          :scanner_count,
          :scanned_resources_count,
          :last_occurrence_hostname,
          :last_occurrence_method_name,
          :last_occurrence_path,
          :last_occurrence_severity,
          :last_occurrence_confidence) do
      :dast                             | 24 | 15 | 1 | 6 | 'http://goat:8080' | 'GET' | '/WebGoat/plugins/bootstrap/css/bootstrap.min.css' | 'info' | 'low'
      :dast_multiple_sites              | 25 | 15 | 1 | 0 | 'http://goat:8080' | 'GET' | '/WebGoat/plugins/bootstrap/css/bootstrap.min.css' | 'info' | 'low'
      :dast_deprecated_no_spider        | 2  | 3  | 1 | 0 | 'http://bikebilly-spring-auto-devops-review-feature-br-3y2gpb.35.192.176.43.xip.io' | 'GET' | '/' | 'low' | 'medium'
      :dast_deprecated_no_common_fields | 24 | 15 | 1 | 0 | 'http://goat:8080' | 'GET' | '/WebGoat/plugins/bootstrap/css/bootstrap.min.css' | 'info' | 'low'
    end

    with_them do
      let(:artifact) { create(:ee_ci_job_artifact, report_format) }

      before do
        parse_report
      end

      it 'parses all identifiers, findings and scanned resources' do
        expect(report.findings.length).to eq(occurrence_count)
        expect(report.identifiers.length).to eq(identifier_count)
        expect(report.scanners.length).to eq(scanner_count)
        expect(report.scanned_resources.length).to eq(scanned_resources_count)
      end

      it 'generates expected location' do
        location = report.findings.last.location
        expect(location).to be_a(::Gitlab::Ci::Reports::Security::Locations::Dast)
        expect(location).to have_attributes(
          hostname: last_occurrence_hostname,
          method_name: last_occurrence_method_name,
          path: last_occurrence_path
        )
      end

      describe 'occurrence properties' do
        where(:attribute, :value) do
          :report_type | 'dast'
          :severity | last_occurrence_severity
          :confidence | last_occurrence_confidence
        end

        with_them do
          it 'saves properly occurrence' do
            occurrence = report.findings.last

            expect(occurrence.public_send(attribute)).to eq(value)
          end
        end
      end
    end

    describe 'parses scanned_resources' do
      it 'creates a scanned resource for each URL' do
        parse_report

        expect(report.scanned_resources.length).to eq(6)
        expect(report.scanned_resources.first).to be_a(::Gitlab::Ci::Reports::Security::ScannedResource)
      end

      context 'when the report has invalid URLs' do
        let(:raw_json) do
          {
            "vulnerabilities": [],
            "remediations": [],
            "dependency_files": [],
            "scan": {
              "scanned_resources": [
                {
                  "method": "GET",
                  "type": "url",
                  "url": "not a URL"
                }
              ]
            }
          }.to_json
        end

        let(:mock_each_blob) { [raw_json].method(:each) }

        before do
          allow(artifact).to receive(:each_blob).and_return(mock_each_blob)
        end

        it 'skips invalid URLs' do
          parse_report

          expect(report.scanned_resources).to be_empty
        end
      end
    end
  end
end
