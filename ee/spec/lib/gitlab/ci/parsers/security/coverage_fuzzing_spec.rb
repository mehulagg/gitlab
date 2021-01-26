# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Gitlab::Ci::Parsers::Security::CoverageFuzzing do
  let(:project) { artifact.project }
  let(:pipeline) { artifact.job.pipeline }
  let(:report) { Gitlab::Ci::Reports::Security::Report.new(artifact.file_type, pipeline, 2.weeks.ago) }
  let(:artifact) { create(:ee_ci_job_artifact, :coverage_fuzzing) }

  describe '#parse!' do
    before do
      artifact.each_blob { |blob| described_class.parse!(blob, report) }
    end

    it 'parses all identifiers and findings' do
      expect(report.findings.length).to eq(1)
      expect(report.scanners.length).to eq(1)
    end

    it 'generates expected location' do
      location = report.findings.first.location

      expect(location).to be_a(::Gitlab::Ci::Reports::Security::Locations::CoverageFuzzing)
      expect(location).to have_attributes(
        "crash_address": "0x602000001573",
        "crash_state": "FuzzMe\nstart\nstart+0x0\n\n",
        "crash_type": "Heap-buffer-overflow\nREAD 1")
    end
  end
end
