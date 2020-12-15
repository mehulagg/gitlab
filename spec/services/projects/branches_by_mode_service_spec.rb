# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Projects::BranchesByModeService do
  let_it_be(:user) { create(:user) }
  let_it_be(:project) { create(:project, :repository) }

  let(:finder) { described_class.new(project, params) }
  let(:params) { { mode: 'all' } }

  subject { finder.execute }

  describe '#execute' do
    context 'page is passed' do
      let(:params) { { page: 4, mode: 'all', offset: 3 } }

      it 'uses offset pagination' do
        expect(finder).to receive(:fetch_branches_via_offset_pagination).and_call_original

        branches, prev_page, next_page = subject

        expect(branches.size).to eq(10)
        expect(next_page).to be_nil
        expect(prev_page).to eq("/#{project.full_path}/-/branches/all?offset=2&page=3")
      end
    end

    context 'search is passed' do
      let(:params) { { search: 'feature' } }

      it 'uses offset pagination' do
        expect(finder).to receive(:fetch_branches_via_offset_pagination).and_call_original

        branches, prev_page, next_page = subject

        expect(branches.map(&:name)).to match_array(%w(feature feature_conflict))
        expect(next_page).to be_nil
        expect(prev_page).to be_nil
      end
    end

    context 'branch_list_keyset_pagination is disabled' do
      it 'uses offset pagination' do
        stub_feature_flags(branch_list_keyset_pagination: false)

        expect(finder).to receive(:fetch_branches_via_offset_pagination).and_call_original

        branches, prev_page, next_page = subject

        expect(branches.size).to eq(20)
        expect(next_page).to eq("/#{project.full_path}/-/branches/all?offset=1&page_token=conflict-resolvable")
        expect(prev_page).to be_nil
      end
    end

    it 'uses gitaly pagination' do
      expect(finder).to receive(:fetch_branches_via_gitaly_pagination).and_call_original

      branches, prev_page, next_page = subject

      expect(branches.size).to eq(20)
      expect(next_page).to eq("/#{project.full_path}/-/branches/all?offset=1&page_token=conflict-resolvable")
      expect(prev_page).to be_nil
    end

    context 'filter by mode' do
      let(:stale) { double(state: 'stale') }
      let(:active) { double(state: 'active') }

      before do
        allow_next_instance_of(BranchesFinder) do |instance|
          allow(instance).to receive(:execute).and_return([stale, active])
        end
      end

      context 'stale' do
        let(:params) { { mode: 'stale' } }

        it 'returns stale branches' do
          is_expected.to eq([[stale], nil, nil])
        end
      end

      context 'active' do
        let(:params) { { mode: 'active' } }

        it 'returns active branches' do
          is_expected.to eq([[active], nil, nil])
        end
      end
    end
  end
end
