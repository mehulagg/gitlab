# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Gitlab::Ci::Parsers::Security::ContainerScanning do
  let(:project) { artifact.project }
  let(:pipeline) { artifact.job.pipeline }
  let(:report) { Gitlab::Ci::Reports::Security::Report.new(artifact.file_type, pipeline, 2.weeks.ago) }

  before do
    artifact.each_blob { |blob| described_class.parse!(blob, report) }
  end

  describe '#parse!' do
    let(:artifact) { create(:ee_ci_job_artifact, :container_scanning) }
    let(:image) { 'registry.gitlab.com/gitlab-org/security-products/dast/webgoat-8.0@sha256:bc09fe2e0721dfaeee79364115aeedf2174cce0947b9ae5fe7c33312ee019a4e' }

    it "parses all identifiers and findings for unapproved vulnerabilities" do
      expect(report.findings.length).to eq(8)
      expect(report.identifiers.length).to eq(8)
      expect(report.scanners).to include("trivy")
      expect(report.scanners.length).to eq(1)
    end

    it 'generates expected location' do
      location = report.findings.first.location

      expect(location).to be_a(::Gitlab::Ci::Reports::Security::Locations::ContainerScanning)
      expect(location).to have_attributes(
        image: image,
        operating_system: 'debian:9',
        package_name: 'glibc',
        package_version: '2.24-11+deb9u3'
      )
    end

    it "generates expected metadata_version" do
      expect(report.findings.first.metadata_version).to eq('2.3')
    end

    it "adds report image's name to raw_metadata" do
      expect(Gitlab::Json.parse(report.findings.first.raw_metadata).dig('location', 'image')).to eq(image)
    end
  end
end
