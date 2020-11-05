# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Security::AutoFixService do
  describe '#execute' do
    subject { described_class.new(project).execute(ids) }

    let(:project) { create(:project, :custom_repo, files: { 'yarn.lock' => yarn_lock_content }) }
    let(:vulnerability_with_rem) { create(:vulnerabilities_finding_with_remediation, :yarn_remediation, report_type: :dependency_scanning, summary: "Test remediation") }

    let(:remediations_folder) { Rails.root.join('ee/spec/fixtures/security_reports/remediations') }
    let(:yarn_lock_content) do
      File.read(
        File.join(remediations_folder, "yarn.lock")
      )
    end

    let(:remediation_diff) do
      Base64.encode64(
        File.read(
          File.join(remediations_folder, "remediation.patch")
        )
      )
    end

    context 'with enabled auto-fix' do
      let!(:setting) { create(:project_security_setting, project: project) }

      let(:ids) { [vulnerability_with_rem.id] }

      it 'creates MR' do
        expect(MergeRequest.count).to eq(0)
        expect(Vulnerabilities::Feedback.count).to eq(0)

        subject

        expect(Vulnerabilities::Feedback.count).to eq(1)
        expect(MergeRequest.count).to eq(1)
        expect(MergeRequest.last.title).to eq('Resolve vulnerability: Cipher with no integrity')
      end
    end
  end
end
