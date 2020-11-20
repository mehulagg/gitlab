# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Analytics::DevopsAdoption::Snapshot, type: :model do
  it { is_expected.to belong_to(:segment) }

  it { is_expected.to validate_presence_of(:segment) }
  it { is_expected.to validate_presence_of(:recorded_at) }

  describe '.latest_snapshot_for_segment_ids' do
    let_it_be(:segment_1) { create(:devops_adoption_segment) }
    let_it_be(:segment_1_oldest_snapshot) { create(:devops_adoption_snapshot, segment: segment_1, recorded_at: 2.weeks.ago) }
    let_it_be(:segment_1_latest_snapshot) { create(:devops_adoption_snapshot, segment: segment_1, recorded_at: 1.week.ago) }

    let_it_be(:segment_2) { create(:devops_adoption_segment) }
    let_it_be(:segment_2_oldest_snapshot) { create(:devops_adoption_snapshot, segment: segment_2, recorded_at: 2.years.ago) }
    let_it_be(:segment_2_latest_snapshot) { create(:devops_adoption_snapshot, segment: segment_2, recorded_at: 1.year.ago) }

    subject { described_class.latest_snapshot_for_segment_ids([segment_1.id, segment_2.id]) }

    it 'returns the latest snapshot for the given segment ids' do
      expect(subject).to match_array([segment_1_latest_snapshot, segment_2_latest_snapshot])
    end
  end
end
