# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Ci::SyncReportsToApprovalRulesService, '#execute' do
  let_it_be(:project) { create(:project, :public, :repository) }

  let(:merge_request) { create(:merge_request, source_project: project) }
  let(:pipeline) { create(:ee_ci_pipeline, :success, project: project, merge_requests_as_head_pipeline: [merge_request]) }
  let(:base_pipeline) { create(:ee_ci_pipeline, :success, project: project, ref: merge_request.target_branch, sha: merge_request.diff_base_sha) }

  subject(:sync_rules) { described_class.new(pipeline).execute }

  before do
    allow(Ci::Pipeline).to receive(:find).with(pipeline.id) { pipeline }

    stub_licensed_features(dependency_scanning: true, dast: true, license_scanning: true)
  end

  context 'with security rules' do
    let(:report_approver_rule) { create(:report_approver_rule, merge_request: merge_request, approvals_required: 2) }

    context 'when there are security reports' do
      context 'when pipeline passes' do
        context 'when high-severity vulnerabilities are present' do
          before do
            create(:ee_ci_build, :success, :dependency_scanning, name: 'ds_job', pipeline: pipeline, project: project)
          end

          context 'when high-severity vulnerabilities already present in target branch pipeline' do
            before do
              create(:ee_ci_build, :success, :dependency_scanning, name: 'ds_job', pipeline: base_pipeline, project: project)
            end

            it 'lowers approvals_required count to zero' do
              expect { subject }
                .to change { report_approver_rule.reload.approvals_required }.from(2).to(0)
            end
          end

          context 'when high-severity vulnerabilities do not present in target branch pipeline' do
            it "won't change approvals_required count" do
              expect { subject }
                .not_to change { report_approver_rule.reload.approvals_required }
            end
          end
        end

        context 'when only low-severity vulnerabilities are present' do
          before do
            create(:ee_ci_build, :success, :low_severity_dast_report, name: 'dast_job', pipeline: pipeline, project: project)
          end

          it 'lowers approvals_required count to zero' do
            expect { subject }
              .to change { report_approver_rule.reload.approvals_required }.from(2).to(0)
          end
        end

        context 'when merge_requests are merged' do
          let!(:merge_request) { create(:merge_request, :merged, source_project: project) }

          before do
            create(:ee_ci_build, :success, :dast, name: 'dast_job', pipeline: pipeline, project: project)
          end

          it "won't change approvals_required count" do
            expect { subject }
              .not_to change { report_approver_rule.reload.approvals_required }
          end
        end

        context "license compliance policy" do
          let!(:license_compliance_rule) { create(:report_approver_rule, :license_scanning, merge_request: merge_request, approvals_required: 1) }

          before do
            stub_feature_flags(drop_license_management_artifact: false)
          end

          context "when a license violates the license compliance policy" do
            let!(:software_license_policy) { create(:software_license_policy, :denied, project: project, software_license: denied_license) }
            let(:denied_license) { create(:software_license, name: license_name) }
            let(:license_name) { ci_build.pipeline.license_scanning_report.license_names[0] }

            context 'with a new report' do
              let!(:ci_build) { create(:ee_ci_build, :success, :license_scanning, pipeline: pipeline, project: project) }

              specify { expect { subject }.not_to change { license_compliance_rule.reload.approvals_required } }
              specify { expect(subject[:status]).to be(:success) }
            end

            context 'with an old report' do
              let!(:ci_build) { create(:ee_ci_build, :success, :license_management, pipeline: pipeline, project: project) }

              specify { expect { subject }.not_to change { license_compliance_rule.reload.approvals_required } }
              specify { expect(subject[:status]).to be(:success) }
            end
          end

          context "when no licenses violate the license compliance policy" do
            context 'with a new report' do
              let!(:ci_build) { create(:ee_ci_build, :success, :license_scanning, pipeline: pipeline, project: project) }

              specify { expect { subject }.to change { license_compliance_rule.reload.approvals_required }.from(1).to(0) }
              specify { expect(subject[:status]).to be(:success) }
            end

            context 'with an old report' do
              let!(:ci_build) { create(:ee_ci_build, :success, :license_management, pipeline: pipeline, project: project) }

              before do
                stub_feature_flags(drop_license_management_artifact: false)
              end

              specify { expect { subject }.to change { license_compliance_rule.reload.approvals_required }.from(1).to(0) }
              specify { expect(subject[:status]).to be(:success) }
            end
          end

          context "when an unexpected error occurs" do
            before do
              allow_next_instance_of(Gitlab::Ci::Reports::LicenseScanning::Report) do |instance|
                allow(instance).to receive(:violates?).and_raise('heck')
              end
            end

            specify { expect(subject[:status]).to be(:error) }
            specify { expect(subject[:message]).to eql("Failed to update approval rules") }
          end
        end
      end

      context 'when pipeline fails' do
        before do
          pipeline.update!(status: :failed)
        end

        context 'when high-severity vulnerabilities are present' do
          before do
            create(:ee_ci_build, :success, :dependency_scanning, name: 'ds_job', pipeline: pipeline, project: project)
          end

          context 'when high-severity vulnerabilities already present in target branch pipeline' do
            before do
              create(:ee_ci_build, :success, :dependency_scanning, name: 'ds_job', pipeline: base_pipeline, project: project)
            end

            it 'lowers approvals_required count to zero' do
              expect { subject }
                .to change { report_approver_rule.reload.approvals_required }.from(2).to(0)
            end
          end

          context 'when high-severity vulnerabilities do not present in target branch pipeline' do
            it "won't change approvals_required count" do
              expect { subject }
                .not_to change { report_approver_rule.reload.approvals_required }
            end
          end
        end

        context 'when only low-severity vulnerabilities are present' do
          before do
            create(:ee_ci_build, :success, :low_severity_dast_report, name: 'dast_job', pipeline: pipeline, project: project)
          end

          it 'lowers approvals_required count to zero' do
            expect { subject }
              .to change { report_approver_rule.reload.approvals_required }.from(2).to(0)
          end
        end
      end
    end

    context 'without security reports' do
      let(:pipeline) { create(:ci_pipeline, :running, project: project, merge_requests_as_head_pipeline: [merge_request]) }

      it "won't change approvals_required count" do
        expect { subject }
          .not_to change { report_approver_rule.reload.approvals_required }
      end

      context "license compliance policy" do
        let!(:software_license_policy) { create(:software_license_policy, :denied, project: project, software_license: denied_license) }
        let!(:license_compliance_rule) { create(:report_approver_rule, :license_scanning, merge_request: merge_request, approvals_required: 1) }
        let!(:denied_license) { create(:software_license) }

        specify { expect { subject }.not_to change { license_compliance_rule.reload.approvals_required } }
        specify { expect(subject[:status]).to be(:success) }
      end
    end
  end

  context 'with code coverage rules' do
    let!(:head_pipeline_builds) do
      [
        create(:ci_build, :success, :trace_with_coverage, trace_coverage: 60.0, pipeline: pipeline),
        create(:ci_build, :success, :trace_with_coverage, trace_coverage: 80.0, pipeline: pipeline),
        create(:ci_build, :success, coverage: nil, pipeline: pipeline),
        create(:ci_build, :success, coverage: 40.0, pipeline: pipeline)
      ]
    end

    let!(:report_approver_rule) { create(:report_approver_rule, :code_coverage, merge_request: merge_request, approvals_required: 2) }

    context 'when pipeline is complete' do
      before do
        allow(pipeline).to receive(:complete?).and_return(true)
      end

      context 'and head pipeline coverage is lower than base pipeline coverage' do
        let!(:base_pipeline_builds) do
          [
            create(:ci_build, :success, coverage: 90.0, pipeline: base_pipeline),
            create(:ci_build, :success, coverage: 100.0, pipeline: base_pipeline)
          ]
        end

        it "won't lower approvals_required count" do
          expect { sync_rules }
            .not_to change { report_approver_rule.reload.approvals_required }
        end
      end

      context 'and head pipeline coverage is higher than base pipeline coverage' do
        let!(:base_pipeline_builds) do
          [
            create(:ci_build, :success, coverage: 60.0, pipeline: base_pipeline),
            create(:ci_build, :success, coverage: 80.0, pipeline: base_pipeline),
            create(:ci_build, :success, coverage: 30.0, pipeline: base_pipeline)
          ]
        end

        it "lowers approvals_required count" do
          expect { sync_rules }
            .to change { report_approver_rule.reload.approvals_required }.from(2).to(0)
        end

        context 'when MR is merged' do
          let!(:merge_request) { create(:merge_request, :merged, source_project: project) }

          it "won't change approvals_required count" do
            expect { subject }
              .not_to change { report_approver_rule.reload.approvals_required }
          end
        end
      end

      context 'and head pipeline coverage is the same as base pipeline coverage' do
        let!(:base_pipeline_builds) do
          [
            create(:ci_build, :success, coverage: 60.0, pipeline: base_pipeline),
            create(:ci_build, :success, coverage: 80.0, pipeline: base_pipeline),
            create(:ci_build, :success, coverage: 40.0, pipeline: base_pipeline)
          ]
        end

        it "lowers approvals_required count" do
          expect { sync_rules }
            .to change { report_approver_rule.reload.approvals_required }.from(2).to(0)
        end
      end
    end

    context 'when pipeline is incomplete' do
      let!(:base_pipeline_builds) do
        [
          create(:ci_build, :success, coverage: 40.0, pipeline: base_pipeline),
          create(:ci_build, :success, coverage: 30.0, pipeline: base_pipeline)
        ]
      end

      before do
        allow(pipeline).to receive(:complete?).and_return(false)
      end

      it "won't lower approvals_required count" do
        expect { sync_rules }
          .not_to change { report_approver_rule.reload.approvals_required }
      end
    end

    context 'when base pipeline is missing' do
      before do
        allow(pipeline).to receive(:complete?).and_return(true)
      end

      it "lowers approvals_required count" do
        expect { sync_rules }
          .to change { report_approver_rule.reload.approvals_required }.from(2).to(0)
      end
    end
  end
end
