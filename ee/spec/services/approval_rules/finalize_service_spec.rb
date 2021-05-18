# frozen_string_literal: true

require 'spec_helper'

RSpec.describe ApprovalRules::FinalizeService do
  let(:project) { create(:project, :repository) }
  let(:merge_request) { create(:merge_request, source_project: project, target_project: project) }

  describe '#execute' do
    let!(:user1) { create(:user) }
    let!(:user2) { create(:user) }
    let!(:user3) { create(:user) }
    let!(:group1) { create(:group) }
    let!(:group2) { create(:group) }
    let!(:group1_user) { create(:user) }
    let!(:group2_user) { create(:user) }
    let!(:approval1) { create(:approval, merge_request: merge_request, user: user1) }
    let!(:approval2) { create(:approval, merge_request: merge_request, user: user3) }
    let!(:approval3) { create(:approval, merge_request: merge_request, user: group1_user) }
    let!(:approval4) { create(:approval, merge_request: merge_request, user: group2_user) }
    let!(:project_rule) { create(:approval_project_rule, project: project, name: 'foo', approvals_required: 12) }

    subject { described_class.new(merge_request) }

    before do
      group1.add_guest(group1_user)
      group2.add_guest(group2_user)

      project_rule.users = [user1, user2]
      project_rule.groups << group1
    end

    shared_examples 'skipping when unmerged' do
      it 'does nothing if unmerged' do
        expect do
          subject.execute
        end.not_to change { ApprovalMergeRequestRule.count }
      end
    end

    context 'when there is no merge request rules' do
      it_behaves_like 'skipping when unmerged'

      context 'when merged' do
        let(:merge_request) { create(:merged_merge_request, source_project: project, target_project: project) }

        before do
          merge_request.approval_rules.code_owner.create!(name: 'Code Owner', rule_type: :code_owner)
        end

        it 'copies project rules to MR, keep snapshot of group member by including it as part of users association' do
          expect do
            subject.execute
          end.to change { ApprovalMergeRequestRule.count }.by(1)

          rule = merge_request.approval_rules.regular.first

          expect(rule.name).to eq('foo')
          expect(rule.approvals_required).to eq(12)
          expect(rule.users).to contain_exactly(user1, user2, group1_user)
          expect(rule.groups).to contain_exactly(group1)

          expect(rule.approved_approvers).to contain_exactly(user1, group1_user)
        end

        shared_examples 'idempotent approval tests' do |rule_type|
          before do
            project_rule.destroy!

            rule = create(:approval_project_rule, project: project, name: 'another rule', approvals_required: 2, rule_type: rule_type)
            rule.users = [user1]
            rule.groups << group1

            # Emulate merge requests approval rules synced with project rule
            mr_rule = create(:approval_merge_request_rule, merge_request: merge_request, name: rule.name, approvals_required: 2, rule_type: rule_type)
            mr_rule.users = rule.users
            mr_rule.groups = rule.groups
          end

          it 'does not create a new rule if one exists' do
            expect do
              2.times { subject.execute }
            end.not_to change { ApprovalMergeRequestRule.count }
          end
        end

        ApprovalProjectRule.rule_types.except(:code_owner, :report_approver).each do |rule_type, _value|
          it_behaves_like 'idempotent approval tests', rule_type
        end
      end
    end

    context 'when there is a regular merge request rule' do
      before do
        rule = create(:approval_merge_request_rule, merge_request: merge_request, name: 'bar', approvals_required: 32)
        rule.users = [user2, user3]
        rule.groups << group2
      end

      it_behaves_like 'skipping when unmerged'

      context 'when merged' do
        let(:merge_request) { create(:merged_merge_request, source_project: project, target_project: project) }

        it 'does not copy project rules, and updates approval mapping with MR rules' do
          allow(subject).to receive(:copy_project_approval_rules)

          expect do
            subject.execute
          end.not_to change { ApprovalMergeRequestRule.count }

          rule = merge_request.approval_rules.regular.first

          expect(rule.name).to eq('bar')
          expect(rule.approvals_required).to eq(32)
          expect(rule.users).to contain_exactly(user2, user3, group2_user)
          expect(rule.groups).to contain_exactly(group2)

          expect(rule.approved_approvers).to contain_exactly(user3, group2_user)
          expect(subject).not_to have_received(:copy_project_approval_rules)
        end

        # Test for https://gitlab.com/gitlab-org/gitlab/issues/13488
        it 'gracefully merges duplicate users' do
          group2.add_developer(user2)

          expect do
            subject.execute
          end.not_to change { ApprovalMergeRequestRule.count }

          rule = merge_request.approval_rules.regular.first

          expect(rule.name).to eq('bar')
          expect(rule.users).to contain_exactly(user2, user3, group2_user)
        end
      end
    end
  end
end
