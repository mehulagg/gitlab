# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Gitlab::GroupSearchResults do
  let!(:user) { build(:user) }
  let!(:group) { create(:group) }

  subject { described_class.new(user, query, group: group) }

  describe '#epics' do
    let(:query) { 'foo' }
    let!(:searchable_epic) { create(:epic, title: 'foo', group: group) }
    let!(:another_searchable_epic) { create(:epic, title: 'foo 2', group: group) }
    let!(:another_epic) { create(:epic) }

    before do
      create(:group_member, group: group, user: user)
      group.add_owner(user)
      stub_licensed_features(epics: true)
    end

    it 'finds epics' do
      expect(subject.objects('epics')).to match_array([searchable_epic, another_searchable_epic])
    end
  end
end
