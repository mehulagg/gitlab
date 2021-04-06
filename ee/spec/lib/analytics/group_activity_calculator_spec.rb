# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Analytics::GroupActivityCalculator do
  subject { described_class.new(group, current_user) }

  let_it_be(:group) { create(:group) }
  let_it_be(:current_user) { create(:user) }
  let_it_be(:subgroup) { create(:group, parent: group) }
  let_it_be(:project) { create(:project, group: subgroup) }
  let_it_be(:secret_subgroup) { create(:group, parent: group) }
  let_it_be(:secret_project) { create(:project, group: secret_subgroup) }

  before do
    subgroup.add_developer(current_user)
    project.add_developer(current_user)
  end

  context 'with issues' do
    let_it_be(:recent_issue) { create(:issue, project: project) }
    let_it_be(:old_issue) do
      create(:issue,
        project: project,
        created_at: 100.days.ago)
    end

    it 'only returns the count of recent issues' do
      expect(subject.issues_count).to eq 1
    end

    context 'when user does not have access to some issues' do
      let(:secret_issue) { create(:issue, project: secret_project) }

      it 'does not include those issues' do
        expect { secret_issue }.not_to change { subject.issues_count}
      end
    end
  end

  context 'with merge requests' do
    it 'calls RecentMergeRequestsCountService#count' do
      expect_next_instance_of(Groups::RecentMergeRequestsCountService) do |count_service|
        expect(count_service).to receive(:count)
      end

      subject.merge_requests_count
    end
  end

  context 'with members' do
    it 'returns the count of recently added members' do
      expect(subject.new_members_count).to eq 1 # current_user
    end

    context 'when there is a member who was not added recently' do
      let(:old_member) { create(:user, created_at: 102.days.ago) }

      before do
        travel_to(100.days.ago) do
          subgroup.add_developer old_member
        end
      end

      it 'returns the count of recently added members' do
        expect(subject.new_members_count).to eq 1 # current_user
      end
    end

    context 'when user does not have access to some members' do
      let(:secret_member) { create(:user) }

      before do
        secret_subgroup.add_developer secret_member
      end

      it 'does not include those members' do
        expect { secret_member }.not_to change { subject.new_members_count }
      end
    end
  end
end
