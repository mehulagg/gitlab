# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Gitlab::Ci::Parsers::Security::Common do
  describe '#parse!' do
    let_it_be(:pipeline) { create(:ci_pipeline) }

    let(:artifact) { build(:ee_ci_job_artifact, :common_security_report) }
    let(:report) { Gitlab::Ci::Reports::Security::Report.new(artifact.file_type, pipeline, 2.weeks.ago) }
    let(:parser) { described_class.new }

    before do
      allow(parser).to receive(:create_location).and_return(nil)
      artifact.each_blob do |blob|
        parser.parse!(blob, report)
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
  end
end
