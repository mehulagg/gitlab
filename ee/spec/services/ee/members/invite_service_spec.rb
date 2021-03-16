# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Members::InviteService, :aggregate_failures do
  let_it_be(:user) { create(:user) }
  let_it_be(:root_ancestor) { create(:group) }
  let_it_be(:project, reload: true) { create(:project, group: root_ancestor) }
  let_it_be(:subgroup) { create(:group, parent: root_ancestor) }
  let_it_be(:subgroup_project) { create(:project, group: subgroup) }

  let(:params) { { email: %w[email@example.org email2@example.org], access_level: Gitlab::Access::GUEST } }

  subject(:result) { described_class.new(user, params).execute(project) }

  before_all do
    project.add_maintainer(user)

    create(:project_member, :invited, project: subgroup_project, created_at: 2.days.ago)
    create(:project_member, :invited, project: subgroup_project)
    create(:group_member, :invited, group: subgroup, created_at: 2.days.ago)
    create(:group_member, :invited, group: subgroup)
  end

  describe '#execute' do
    context 'with group plan' do
      let(:plan_limits) { create(:plan_limits, daily_invites: daily_invites) }
      let(:plan) { create(:plan, limits: plan_limits) }
      let!(:subscription) do
        create(
          :gitlab_subscription,
          namespace: root_ancestor,
          hosted_plan: plan
        )
      end

      shared_examples 'quota limit exceeded' do |limit|
        it 'limits the number of daily invites allowed' do
          expect { result }.not_to change(ProjectMember, :count)
          expect(result[:status]).to eq(:error)
          expect(result[:message]).to eq("Invite limit of #{limit} per day exceeded")
        end
      end

      context 'already exceeded invite quota limit' do
        let(:daily_invites) { 2 }

        it_behaves_like 'quota limit exceeded', 2
      end

      context 'will exceed invite quota limit' do
        let(:daily_invites) { 3 }

        it_behaves_like 'quota limit exceeded', 3
      end

      context 'within invite quota limit' do
        let(:daily_invites) { 5 }

        it 'successfully creates members' do
          expect { result }.to change(ProjectMember, :count).by(2)
          expect(result[:status]).to eq(:success)
        end
      end

      context 'infinite invite quota limit' do
        let(:daily_invites) { 0 }

        it 'successfully creates members' do
          expect { result }.to change(ProjectMember, :count).by(2)
          expect(result[:status]).to eq(:success)
        end
      end
    end

    context 'without a plan' do
      let(:plan) { nil }

      it 'successfully creates members' do
        expect { result }.to change(ProjectMember, :count).by(2)
        expect(result[:status]).to eq(:success)
      end
    end
  end
end
