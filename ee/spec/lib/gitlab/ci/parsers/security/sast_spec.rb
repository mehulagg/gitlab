# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Gitlab::Ci::Parsers::Security::Sast do
  using RSpec::Parameterized::TableSyntax

  describe '#parse!' do
    let_it_be(:pipeline) { create(:ci_pipeline) }

    let(:created_at) { 2.weeks.ago }

    subject(:parser) { described_class.new }

    context "when parsing valid reports" do
      where(:report_format, :scanner_length) do
        :sast               | 4
        :sast_deprecated    | 3
      end

      with_them do
        let(:report) { Gitlab::Ci::Reports::Security::Report.new(artifact.file_type, pipeline, created_at) }
        let(:artifact) { create(:ee_ci_job_artifact, report_format) }

        before do
          artifact.each_blob do |blob|
            parser.parse!(blob, report)
          end
        end

        it "parses all identifiers and findings" do
          expect(report.findings.length).to eq(33)
          expect(report.identifiers.length).to eq(17)
          expect(report.scanners.length).to eq(scanner_length)
        end

        it 'generates expected location' do
          location = report.findings.first.location

          expect(location).to be_a(::Gitlab::Ci::Reports::Security::Locations::Sast)
          expect(location).to have_attributes(
            file_path: 'python/hardcoded/hardcoded-tmp.py',
            start_line: 1,
            end_line: 1,
            class_name: nil,
            method_name: nil
          )
        end

        it "generates expected metadata_version" do
          expect(report.findings.first.metadata_version).to eq('1.2')
        end
      end
    end

    context "when parsing an empty report" do
      let(:report) { Gitlab::Ci::Reports::Security::Report.new('sast', pipeline, created_at) }
      let(:blob) { Gitlab::Json.generate({}) }

      it { expect(parser.parse!(blob, report)).to be_empty }
    end
  end
end
