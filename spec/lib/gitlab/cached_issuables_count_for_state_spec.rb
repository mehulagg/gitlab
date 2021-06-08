# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Gitlab::CachedIssuablesCountForState, :use_clean_rails_redis_caching do
  let_it_be(:user) { create(:user) }
  let_it_be(:group) { create(:group, :public) }
  let_it_be(:project) { create(:project, :public, :repository, namespace: group) }

  let(:counter) { described_class.new(finder, group) }

  describe '#[]' do
    context 'with issues' do
      let_it_be(:issue1) { create(:issue, project: project) }
      let_it_be(:issue2) { create(:issue, project: project) }
      let_it_be(:issue3) { create(:issue, project: project) }
      let_it_be(:closed) { create(:issue, :closed, project: project) }
      let_it_be(:confidential) { create(:issue, :confidential, project: project) }

      let(:finder) do
        IssuesFinder.new(user, group_id: group.id, non_archived: true, include_subgroups: true)
      end

      context 'when user is not a member' do
        it 'returns the number of issuables for the given state' do
          expect(counter[:opened]).to eq(3)
          expect(counter[:closed]).to eq(1)
          expect(counter[:all]).to eq(4)
        end

        it 'casts valid states from Strings to Symbols' do
          expect(counter['closed']).to eq(1)
        end

        it 'returns 0 when using an invalid state name as a String' do
          expect(counter['kittens']).to be_zero
        end

        it 'reads from cache with correct key' do
          counts = { opened: 3, closed: 1, all: 4 }
          allow(Rails.cache).to receive(:fetch).and_return(counts)
          expect(Rails.cache).to receive(:fetch)
            .with(
              ['group', group.id, "#{finder.class.to_s.underscore}_count_for_state", 'public'],
              { expires_in: described_class::EXPIRATION_TIME, skip_nil: true }
            )
          counter[:all]
        end
      end

      context 'when user is a reporter' do
        before do
          group.add_reporter(user)
        end

        it 'returns the number of issuables for the given state' do
          expect(counter[:opened]).to eq(4)
          expect(counter[:closed]).to eq(1)
          expect(counter[:all]).to eq(5)
        end

        it 'reads from cache with correct key' do
          counts = { opened: 4, closed: 1, all: 5 }
          allow(Rails.cache).to receive(:fetch).and_return(counts)
          expect(Rails.cache).to receive(:fetch)
            .with(
              ['group', group.id, "#{finder.class.to_s.underscore}_count_for_state", 'total'],
              { expires_in: described_class::EXPIRATION_TIME, skip_nil: true }
            )
          counter[:all]
        end
      end
    end
  end
end
