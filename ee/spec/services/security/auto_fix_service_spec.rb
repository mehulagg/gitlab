# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Security::AutoFixService do
  describe '#execute' do
    subject(:execute_service) { described_class.new(project, pipeline).execute }

    let(:pipeline) { create(:ee_ci_pipeline, :success, project: project) }
    let(:project) { create(:project, :custom_repo, files: { 'yarn.lock' => yarn_lock_content }) }
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
      context 'when remediations exist' do
        before do
          create(:vulnerabilities_finding_with_remediation, :yarn_remediation,
                 project: project,
                 pipelines: [pipeline],
                 report_type: :dependency_scanning,
                 summary: 'Test remediation')
        end

        it 'creates MR' do
          expect(MergeRequest.count).to eq(0)
          expect(Vulnerabilities::Feedback.count).to eq(0)

          execute_service

          expect(Vulnerabilities::Feedback.count).to eq(1)
          expect(MergeRequest.count).to eq(1)
          expect(MergeRequest.last.title).to eq("Resolve vulnerability: Cipher with no integrity")
        end

        context 'when running second time' do
          it 'does not create second merge request' do
            execute_service

            expect(Vulnerabilities::Feedback.count).to eq(1)
            expect(MergeRequest.count).to eq(1)

            execute_service

            expect(Vulnerabilities::Feedback.count).to eq(1)
            expect(MergeRequest.count).to eq(1)
          end
        end
      end

      context 'without remediations' do
        before do
          create(:vulnerabilities_finding, report_type: :dependency_scanning, pipelines: [pipeline], project: project)
        end

        it 'does not create merge request' do
          execute_service

          expect(Vulnerabilities::Feedback.count).to eq(0)
          expect(MergeRequest.count).to eq(0)
        end
      end
    end

    context 'with disabled auto-fix' do
      before do
        create(:project_security_setting, project: project, auto_fix_dependency_scanning: false)

        create(:vulnerabilities_finding_with_remediation, :yarn_remediation,
               project: project,
               pipelines: [pipeline],
               report_type: :dependency_scanning,
               summary: 'Test remediation')
      end

      it 'does not create MR' do
        expect{execute_service}.not_to change{MergeRequest.count}
        expect{execute_service}.not_to change{Vulnerabilities::Feedback.count}
      end
    end
  end
end
