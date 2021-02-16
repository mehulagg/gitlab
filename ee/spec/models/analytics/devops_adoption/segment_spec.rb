# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Analytics::DevopsAdoption::Segment, type: :model do
  describe 'associations' do
    subject { build(:devops_adoption_segment) }

    it { is_expected.to have_many(:snapshots) }
    it { is_expected.to belong_to(:namespace) }
  end

  describe 'validation' do
    subject { build(:devops_adoption_segment) }

    it { is_expected.to validate_presence_of(:namespace) }
    it { is_expected.to validate_uniqueness_of(:namespace) }
  end

  describe '.ordered_by_name' do
    subject(:segments) { described_class.ordered_by_name }

    it 'orders segments by namespace name' do
      segment_1 = create(:devops_adoption_segment, namespace: create(:group, name: 'bbb'))
      segment_2 = create(:devops_adoption_segment, namespace: create(:group, name: 'aaa'))

      expect(segments).to eq([segment_2, segment_1])
    end
  end

  describe '.latest_snapshot' do
    it 'loads the latest snapshot' do
      segment = create(:devops_adoption_segment)
      latest_snapshot = create(:devops_adoption_snapshot, segment: segment, recorded_at: 2.days.ago)
      create(:devops_adoption_snapshot, segment: segment, recorded_at: 5.days.ago)
      create(:devops_adoption_snapshot, segment: create(:devops_adoption_segment), recorded_at: 1.hour.ago)

      expect(segment.latest_snapshot).to eq(latest_snapshot)
    end
  end
end
