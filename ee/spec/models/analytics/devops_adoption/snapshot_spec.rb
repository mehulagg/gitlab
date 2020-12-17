# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Analytics::DevopsAdoption::Snapshot, type: :model do
  it { is_expected.to belong_to(:segment) }

  it { is_expected.to validate_presence_of(:segment) }
  it { is_expected.to validate_presence_of(:recorded_at) }
  it { is_expected.to validate_presence_of(:end_time) }

  describe '.latest_snapshot_for_segment_ids' do
    it 'returns the latest snapshot for the given segment ids based on snapshot end_time' do
      segment_1 = create(:devops_adoption_segment)
      segment_1_latest_snapshot = create(:devops_adoption_snapshot, segment: segment_1, end_time: 1.week.ago)
      create(:devops_adoption_snapshot, segment: segment_1, end_time: 2.weeks.ago)

      segment_2 = create(:devops_adoption_segment)
      segment_2_latest_snapshot = create(:devops_adoption_snapshot, segment: segment_2, end_time: 1.year.ago)
      create(:devops_adoption_snapshot, segment: segment_2, end_time: 2.years.ago)

      latest_snapshot_for_segments = described_class.latest_snapshot_for_segment_ids([segment_1.id, segment_2.id])

      expect(latest_snapshot_for_segments).to match_array([segment_1_latest_snapshot, segment_2_latest_snapshot])
    end
  end

  describe '#start_time' do
    subject(:segment) { described_class.new(end_time: end_time) }

    let(:end_time) { DateTime.parse('2020-12-17') }
    let(:expected_start_time) { DateTime.parse('2020-12-01') }

    it 'is start of the month of end_time' do
      expect(segment.start_time).to eq(expected_start_time)
    end
  end
end
