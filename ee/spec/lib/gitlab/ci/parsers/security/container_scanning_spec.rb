# frozen_string_literal: true

require 'spec_helper'

describe Gitlab::Ci::Parsers::Security::ContainerScanning do
  let(:parser) { described_class.new }

  let(:clair_vulnerabilities) do
    JSON.parse!(
      File.read(
        Rails.root.join('spec/fixtures/security-reports/master/gl-container-scanning-report.json')
      )
    )['vulnerabilities']
  end

  describe '#parse!' do
    let(:project) { artifact.project }
    let(:pipeline) { artifact.job.pipeline }
    let(:artifact) { create(:ee_ci_job_artifact, :container_scanning) }
    let(:report) { Gitlab::Ci::Reports::Security::Report.new(artifact.file_type, pipeline.sha) }

    before do
      artifact.each_blob do |blob|
        parser.parse!(blob, report)
      end
    end

    it "parses all identifiers and occurrences for unapproved vulnerabilities" do
      expect(report.occurrences.length).to eq(8)
      expect(report.identifiers.length).to eq(8)
      expect(report.scanners.length).to eq(1)
    end

    it 'generates expected location' do
      location = report.occurrences.first.location

      expect(location).to be_a(::Gitlab::Ci::Reports::Security::Locations::ContainerScanning)
      expect(location).to have_attributes(
        image: 'registry.gitlab.com/groulot/container-scanning-test/master:5f21de6956aee99ddb68ae49498662d9872f50ff',
        operating_system: 'debian:9',
        package_name: 'glibc',
        package_version: '2.24-11+deb9u3'
      )
    end

    it "generates expected metadata_version" do
      expect(report.occurrences.first.metadata_version).to eq('1.3')
    end

    it "adds report image's name to raw_metadata" do
      expect(JSON.parse(report.occurrences.first.raw_metadata).dig('location', 'image'))
        .to eq('registry.gitlab.com/groulot/container-scanning-test/master:5f21de6956aee99ddb68ae49498662d9872f50ff')
    end
  end
end
