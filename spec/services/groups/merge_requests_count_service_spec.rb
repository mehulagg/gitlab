# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Groups::MergeRequestsCountService, :use_clean_rails_memory_store_caching do
  let_it_be(:user) { create(:user) }
  let_it_be(:group) { create(:group, :public)}
  let_it_be(:project) { create(:project, :repository, namespace: group) }
  let_it_be(:merge_requests) do
    [create(:merge_request, state: 'opened', source_project: project, target_project: project),
     create(:merge_request, state: 'closed', source_project: project, target_project: project),
     create(:merge_request, state: 'closed', source_project: project, target_project: project),
     create(:merge_request, state: 'merged', source_project: project, target_project: project),
     create(:merge_request, state: 'merged', source_project: project, target_project: project),
     create(:merge_request, state: 'merged', source_project: project, target_project: project)]
  end

  subject { described_class.new(group, user) }

  describe '#count' do
    before do
      group.add_reporter(user)
      allow(MergeRequestsFinder).to receive(:new).and_call_original
      allow(Gitlab::IssuablesCountForState).to receive(:new).and_call_original
    end

    it 'uses Gitlab::IssuablesCountForState to fetch counts for each state' do
      expect(subject.count('opened')).to eq 1
      expect(subject.count('closed')).to eq 2
      expect(subject.count('merged')).to eq 3
      expect(subject.count('all')).to eq 6
      expect(subject.count('non-existent')).to eq 0
    end

    context 'acts like a counter caching service with threshold' do
      let(:state) { 'opened' }
      let(:state_counter) { double('count for state', :[] => -1) }
      let(:cache_key) { subject.cache_key(state) }
      let(:under_threshold) { described_class::CACHED_COUNT_THRESHOLD - 1 }
      let(:over_threshold) { described_class::CACHED_COUNT_THRESHOLD + 1 }

      context 'when cache is empty' do
        before do
          Rails.cache.delete(cache_key)
          allow(Gitlab::IssuablesCountForState).to receive(:new).and_return(state_counter)
        end

        it 'refreshes cache if value over threshold' do
          allow(state_counter).to receive(:[]).with(state).and_return(over_threshold)

          expect(subject.count('opened')).to eq(over_threshold)
          expect(Rails.cache.read(cache_key)).to eq(over_threshold)
        end

        it 'does not refresh cache if value under threshold' do
          allow(state_counter).to receive(:[]).with(state).and_return(under_threshold)

          expect(subject.count('opened')).to eq(under_threshold)
          expect(Rails.cache.read(cache_key)).to be_nil
        end
      end

      context 'when cached count is under the threshold value' do
        before do
          Rails.cache.write(cache_key, under_threshold)
        end

        it 'does not refresh cache' do
          expect(Rails.cache).not_to receive(:write)
          expect(subject.count('opened')).to eq(under_threshold)
        end
      end

      context 'when cached count is over the threshold value' do
        before do
          Rails.cache.write(cache_key, over_threshold)
        end

        it 'does not refresh cache' do
          expect(Rails.cache).not_to receive(:write)
          expect(subject.count('opened')).to eq(over_threshold)
        end
      end
    end
  end
end
