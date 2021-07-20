# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Gitlab::GroupSearchResults do
  let!(:user) { build(:user) }
  let!(:group) { create(:group) }

  subject { described_class.new(user, query, group: group) }

  before do
    create(:group_member, group: group, user: user)
    group.add_owner(user)
    stub_licensed_features(epics: true)
  end

  describe '#epics' do
    context 'searching' do
      let(:query) { 'foo' }
      let!(:searchable_epic) { create(:epic, title: 'foo', group: group) }
      let!(:another_searchable_epic) { create(:epic, title: 'foo 2', group: group) }
      let!(:another_epic) { create(:epic) }

      it 'finds epics' do
        expect(subject.objects('epics')).to match_array([searchable_epic, another_searchable_epic])
      end
    end

    context 'ordering' do
      let(:scope) { 'epics' }
      let(:filters) { {} }

      let!(:old_result) { create(:epic, group: group, title: 'sorted old', created_at: 1.month.ago) }
      let!(:new_result) { create(:epic, group: group, title: 'sorted recent', created_at: 1.day.ago) }
      let!(:very_old_result) { create(:epic, group: group, title: 'sorted very old', created_at: 1.year.ago) }

      let!(:old_updated) { create(:epic, group: group, title: 'updated old', updated_at: 1.month.ago) }
      let!(:new_updated) { create(:epic, group: group, title: 'updated recent', updated_at: 1.day.ago) }
      let!(:very_old_updated) { create(:epic, group: group, title: 'updated very old', updated_at: 1.year.ago) }

      include_examples 'search results sorted' do
        let(:results_created) { described_class.new(user, 'sorted', Project.order(:id), group: group, sort: sort, filters: filters) }
        let(:results_updated) { described_class.new(user, 'updated', Project.order(:id), group: group, sort: sort, filters: filters) }
      end
    end
  end
end
