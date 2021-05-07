# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Groups::RecentMergeRequestsCountService, :use_clean_rails_memory_store_caching do
  let_it_be(:group) { create(:group) }
  let_it_be(:user) { create(:user) }
  let_it_be(:project) { create(:project, group: group) }
  let_it_be(:secret_subgroup) { create(:group, parent: group) }
  let_it_be(:secret_project) { create(:project, group: secret_subgroup) }
  let_it_be(:secret_user) { create(:user) }
  let_it_be(:params) do
    { group_id: group.id,
      state: 'all',
      created_after: 90.days.ago,
      include_subgroups: true,
      attempt_group_search_optimizations: true,
      attempt_project_search_optimizations: true }
  end

  subject { described_class.new(group, user, params) }

  before_all do
    project.add_developer(user)
    project.add_developer(secret_user)
    secret_project.add_developer(secret_user)
  end

  describe '#relation_for_count' do
    before do
      allow(MergeRequestsFinder).to receive(:new).and_call_original
    end

    it 'uses the MergeRequestsFinder to scope issues' do
      expect(MergeRequestsFinder).to receive(:new).with(user, params)

      subject.count
    end
  end

  describe '#count' do
    it 'only returns the count of recent MRs' do
      create(:merge_request,
        source_project: project,
        source_branch: "my-personal-branch-1")

      create(:merge_request,
        source_project: project,
        source_branch: "my-personal-branch-2",
        created_at: 100.days.ago)

      expect(subject.count).to eq 1
    end

    context 'when user does not have access to some MRs' do
      it 'caches per-user so users will see the correct value' do
        regular_user_count = subject.count

        expect do
          create(:merge_request, source_project: secret_project)
          # Delete both caches to ensure that the new count gets the updated values
          described_class.new(group, secret_user, params).delete_cache
          subject.delete_cache
        end.to change { described_class.new(group, secret_user, params).count }

        expect(subject.count).to eq(regular_user_count)
      end

      it 'does not include those MRs' do
        expect do
          create(:merge_request, source_project: secret_project)
          subject.delete_cache
        end.not_to change { subject.count }
      end
    end
  end
end
