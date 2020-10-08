# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Security::AutoFixService do
  describe '#execute' do
    subject { described_class.new(project).execute(ids) }

    let_it_be(:project) { create(:project) }
    let_it_be(:vulnerability_with_rem) { create(:vulnerabilities_finding_with_remediation, report_type: :dependency_scanning, summary: "Test remediation") }

    context 'with enabled auto-fix' do
      let!(:setting) { create(:project_security_setting, project: project) }

      let(:ids) { [vulnerability_with_rem.id] }

      it 'creates MR' do
        expect(MergeRequest.count).to eq(0)
        expect(Vulnerabilities::Feedback.count).to eq(0)

        subject

        expect(Vulnerabilities::Feedback.count).to eq(1)
        expect(MergeRequest.count).to eq(1)
      end
    end
  end
end
