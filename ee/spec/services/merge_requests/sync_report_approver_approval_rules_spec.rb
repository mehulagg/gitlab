# frozen_string_literal: true

require 'spec_helper'

RSpec.describe MergeRequests::SyncReportApproverApprovalRules do
  subject(:service) { described_class.new(merge_request) }

  let(:merge_request) { create(:merge_request) }

  describe '#execute' do
    before do
      stub_licensed_features(report_approver_rules: true)
    end

    context "when a project has a single `#{ApprovalProjectRule::DEFAULT_NAME_FOR_SECURITY_REPORT}` approval rule" do
      let!(:security_approval_project_rule) { create(:approval_project_rule, :security_report, project: merge_request.target_project, approvals_required: 2) }

      context 'when report_approver_rules are enabled' do
        let!(:regular_approval_project_rule) { create(:approval_project_rule, project: merge_request.target_project) }

        it 'creates rule for report approvers' do
          expect { service.execute }
            .to change { merge_request.approval_rules.security_report.count }.from(0).to(1)

          rule = merge_request.approval_rules.security_report.first

          expect(rule).to be_report_approver
          expect(rule.report_type).to eq 'security'
          expect(rule.name).to eq(security_approval_project_rule.name)
          expect(rule.approval_project_rule).to eq(security_approval_project_rule)
        end

        it 'updates previous rules if defined' do
          mr_rule = create(:report_approver_rule, merge_request: merge_request, approvals_required: 0)

          expect { service.execute }
            .not_to change { merge_request.approval_rules.security_report.count }

          expect(mr_rule.reload).to be_report_approver
          expect(mr_rule.report_type).to eq 'security'
          expect(mr_rule.name).to eq(security_approval_project_rule.name)
          expect(mr_rule.approvals_required).to eq security_approval_project_rule.approvals_required
          expect(mr_rule.approval_project_rule).to eq(security_approval_project_rule)
        end
      end
    end

    context "when a project has a single `#{ApprovalProjectRule::DEFAULT_NAME_FOR_LICENSE_REPORT}` approval rule" do
      let!(:project_rule) { create(:approval_project_rule, :license_scanning, project: merge_request.target_project) }

      context "when the rule has not been synchronized to the merge request yet" do
        let(:result) { merge_request.reload.approval_rules.last }

        before do
          service.execute
        end

        specify { expect(merge_request.reload.approval_rules.count).to be(1) }
        specify { expect(result).to be_report_approver }
        specify { expect(result.report_type).to eq('license_scanning') }
        specify { expect(result.name).to eq(project_rule.name) }
        specify { expect(result.approval_project_rule).to eq(project_rule) }
        specify { expect(result.approvals_required).to eql(project_rule.approvals_required) }
      end

      context "when the rule had previously been synchronized" do
        let!(:previous_rule) { create(:report_approver_rule, :license_scanning, merge_request: merge_request) }

        before do
          service.execute
        end

        specify { expect(merge_request.reload.approval_rules.count).to be(1) }
        specify { expect(merge_request.reload.approval_rules[0]).to eql(previous_rule) }
      end
    end

    context "when a project has multiple report approval rules" do
      let!(:vulnerability_project_rule) { create(:approval_project_rule, :security_report, project: merge_request.target_project) }
      let!(:license_compliance_project_rule) { create(:approval_project_rule, :license_scanning, project: merge_request.target_project) }

      context "when none of the rules have been synchronized to the merge request yet" do
        let(:vulnerability_check_rule) { merge_request.reload.approval_rules.security.last }
        let(:license_check_rule) { merge_request.reload.approval_rules.find_by(name: ApprovalProjectRule::DEFAULT_NAME_FOR_LICENSE_REPORT) }

        before do
          vulnerability_project_rule.users << create(:user)
          vulnerability_project_rule.groups << create(:group)
          license_compliance_project_rule.users << create(:user)
          license_compliance_project_rule.groups << create(:group)

          service.execute
        end

        specify { expect(merge_request.reload.approval_rules.count).to be(2) }
        specify { expect(vulnerability_check_rule).to be_report_approver }
        specify { expect(vulnerability_check_rule.approvals_required).to eql(vulnerability_project_rule.approvals_required) }
        specify { expect(vulnerability_check_rule).to be_security }
        specify { expect(vulnerability_check_rule.name).to eq(vulnerability_project_rule.name) }
        specify { expect(vulnerability_check_rule.approval_project_rule).to eq(vulnerability_project_rule) }
        specify { expect(license_check_rule).to be_report_approver }
        specify { expect(license_check_rule.approvals_required).to eql(license_compliance_project_rule.approvals_required) }
        specify { expect(license_check_rule).to be_license_scanning }
        specify { expect(license_check_rule.name).to eq(license_compliance_project_rule.name) }
        specify { expect(license_check_rule.approval_project_rule).to eq(license_compliance_project_rule) }
      end

      context "when some of the rules have been synchronized to the merge request" do
        let!(:previous_rule) { create(:report_approver_rule, :license_scanning, merge_request: merge_request) }

        before do
          service.execute
        end

        specify { expect(merge_request.reload.approval_rules.count).to be(2) }
        specify { expect(merge_request.reload.approval_rules.security_report.count).to be(1) }
        specify { expect(merge_request.reload.approval_rules.where(report_type: :license_scanning)).to match_array([previous_rule]) }
      end
    end

    context 'when report_approver_rules are disabled' do
      it 'copies nothing' do
        expect { service.execute }
          .not_to change { merge_request.approval_rules.count }
      end
    end
  end
end
