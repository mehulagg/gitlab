# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Gitlab::Ci::Parsers::Security::DependencyScanning do
  using RSpec::Parameterized::TableSyntax

  describe '#parse!' do
    let(:project) { artifact.project }
    let(:pipeline) { artifact.job.pipeline }
    let(:report) { Gitlab::Ci::Reports::Security::Report.new(artifact.file_type, pipeline, 2.weeks.ago) }

    subject(:parse_report) { artifact.each_blob { |blob| described_class.new(blob, report).parse! } }

    where(:report_format, :finding_count, :identifier_count, :scanner_count, :file_path, :package_name, :package_version, :version) do
      :dependency_scanning             | 4 | 7 | 3 | 'app/pom.xml' | 'io.netty/netty' | '3.9.1.Final' | '1.3'
      :dependency_scanning_deprecated  | 4 | 7 | 2 | 'app/pom.xml' | 'io.netty/netty' | '3.9.1.Final' | '1.3'
      :dependency_scanning_remediation | 2 | 3 | 1 | 'yarn.lock'   | 'debug'          | '1.0.5'       | '2.0'
    end

    with_them do
      let(:artifact) { create(:ee_ci_job_artifact, report_format) }

      before do
        parse_report
      end

      it "parses all identifiers and findings" do
        expect(report.findings.length).to eq(finding_count)
        expect(report.identifiers.length).to eq(identifier_count)
        expect(report.scanners.length).to eq(scanner_count)
      end

      it 'generates expected location' do
        location = report.findings.first.location

        expect(location).to be_a(::Gitlab::Ci::Reports::Security::Locations::DependencyScanning)
        expect(location).to have_attributes(
          file_path: file_path,
          package_name: package_name,
          package_version: package_version
        )
      end

      it "generates expected metadata_version" do
        expect(report.findings.first.metadata_version).to eq(version)
      end
    end

    context 'with missing data' do
      let(:artifact) { create(:ee_ci_job_artifact, :dependency_scanning) }
      let(:report_hash) { Gitlab::Json.parse(fixture_file('security_reports/master/gl-sast-report.json', dir: 'ee'), symbolize_names: true) }
      let(:mock_each_blob) { [report_with_missing_data].method(:each) }

      before do
        allow(artifact).to receive(:each_blob).and_return(mock_each_blob)
      end

      context "when parsing a vulnerability with a missing location" do
        let(:report_with_missing_data) { report_hash.tap { |h| h[:vulnerabilities][0][:location] = nil }.to_json }

        it { expect { parse_report }.not_to raise_error }
      end

      context "when parsing a vulnerability with a missing cve" do
        let(:report_with_missing_data) { report_hash.tap { |h| h[:vulnerabilities][0][:cve] = nil }.to_json }

        it { expect { parse_report }.not_to raise_error }
      end
    end

    context "when vulnerabilities have remediations" do
      let(:artifact) { create(:ee_ci_job_artifact, :dependency_scanning_remediation) }

      before do
        parse_report
      end

      it "generates finding with expected remediation" do
        finding = report.findings.last
        raw_metadata = Gitlab::Json.parse!(finding.raw_metadata)

        expect(finding.name).to eq("Authentication bypass via incorrect DOM traversal and canonicalization in saml2-js")
        expect(raw_metadata["remediations"].first["summary"]).to eq("Upgrade saml2-js")
        expect(raw_metadata["remediations"].first["diff"]).to start_with("ZGlmZiAtLWdpdCBhL3lhcm4")
      end
    end
  end
end
