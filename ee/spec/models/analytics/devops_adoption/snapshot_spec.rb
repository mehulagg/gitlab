# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Analytics::DevopsAdoption::Snapshot, type: :model do
  it { is_expected.to belong_to(:segment) }

  it { is_expected.to validate_presence_of(:segment) }
  it { is_expected.to validate_presence_of(:recorded_at) }

  describe '.latest_snapshot_for_segment_ids' do
    it 'returns the latest snapshot for the given segment ids' do
      segment_1 = create(:devops_adoption_segment)
      segment_1_latest_snapshot = create(:devops_adoption_snapshot, segment: segment_1, recorded_at: 1.week.ago)
      create(:devops_adoption_snapshot, segment: segment_1, recorded_at: 2.weeks.ago)

      segment_2 = create(:devops_adoption_segment)
      segment_2_latest_snapshot = create(:devops_adoption_snapshot, segment: segment_2, recorded_at: 1.year.ago)
      create(:devops_adoption_snapshot, segment: segment_2, recorded_at: 2.years.ago)

      latest_snapshot_for_segments = described_class.latest_snapshot_for_segment_ids([segment_1.id, segment_2.id])

      expect(latest_snapshot_for_segments).to match_array([segment_1_latest_snapshot, segment_2_latest_snapshot])
    end
  end

  describe '#end_time' do
    subject(:segment) { described_class.new(recorded_at: 5.days.ago) }

    it 'equals to recorded_at' do
      expect(segment.end_time).to eq(segment.recorded_at)
    end
  end

  describe '#start_time' do
    subject(:segment) { described_class.new(recorded_at: 3.days.ago) }

    it 'calcualtes a one-month period from end_time' do
      expected_end_time = (segment.end_time - 1.month).at_beginning_of_day

      expect(segment.start_time).to eq(expected_end_time)
    end
  end
end
