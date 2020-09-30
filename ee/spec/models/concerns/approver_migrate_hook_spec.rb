# frozen_string_literal: true

require 'spec_helper'

RSpec.describe ApproverMigrateHook do
  def members(rule)
    rule.users.reload + rule.groups.reload
  end

  context 'create rule and member mapping' do
    shared_examples 'migrating approver' do
      context 'when approver is created' do
        it 'creates rule and member mapping' do
          expect do
            approver
          end.to change { target.approval_rules.count }.by(1)

          rule = target.approval_rules.regular.last

          expect(rule.approvals_required).to eq(0)
          expect(rule.name).to eq('Default')
          expect(members(rule)).to contain_exactly(approver.member)
        end

        context 'when rule already exists' do
          let!(:approval_rule) { target.approval_rules.create!(name: 'foo') }

          it 'reuses rule' do
            expect do
              approver
            end.not_to change { target.approval_rules.regular.count }

            rule = target.approval_rules.regular.last

            expect(rule).to eq(approval_rule)
            expect(members(rule)).to contain_exactly(approver.member)
          end

          context 'when member mapping already exists' do
            before do
              case member
              when User
                approval_rule.users << member
              when Group
                approval_rule.groups << member
              end
            end

            it 'does nothing' do
              approver

              expect(members(approval_rule)).to contain_exactly(approver.member)
            end
          end
        end
      end

      context 'when approver is destroyed' do
        it 'destroys rule member' do
          approver

          rule = target.approval_rules.regular.first

          expect do
            approver.destroy!
          end.to change { members(rule).count }.by(-1)
        end
      end
    end

    context 'User' do
      let(:member) { create(:user) }
      let(:approver) { create(:approver, target: target, user: member) }

      context 'merge request' do
        let(:target) { create(:merge_request) }

        it_behaves_like 'migrating approver'
      end

      context 'project' do
        let(:target) { create(:project) }

        it_behaves_like 'migrating approver'
      end
    end

    context 'Group' do
      let(:member) { create(:group) }
      let(:approver) { create(:approver_group, target: target, group: member) }

      context 'merge request' do
        let(:target) { create(:merge_request) }

        it_behaves_like 'migrating approver'
      end

      context 'project' do
        let(:target) { create(:project) }

        it_behaves_like 'migrating approver'
      end
    end
  end
end
