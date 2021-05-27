# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Analytics::DevopsAdoption::Snapshot, type: :model do
  it { is_expected.to belong_to(:namespace) }

  it { is_expected.to validate_presence_of(:namespace) }
  it { is_expected.to validate_presence_of(:recorded_at) }
  it { is_expected.to validate_presence_of(:end_time) }

  describe '.latest_snapshot_for_namespace_ids' do
    it 'returns the latest snapshot for the given namespace ids based on snapshot end_time' do
      group1 = create(:group)
      group1_latest_snapshot = create(:devops_adoption_snapshot, namespace: group1, end_time: 1.week.ago)
      create(:devops_adoption_snapshot, namespace: group1, end_time: 2.weeks.ago)

      group2 = create(:group)
      group2_latest_snapshot = create(:devops_adoption_snapshot, namespace: group2, end_time: 1.year.ago)
      create(:devops_adoption_snapshot, namespace: group2, end_time: 2.years.ago)

      latest_snapshots = described_class.latest_snapshot_for_namespace_ids([group1.id, group2.id])

      expect(latest_snapshots).to match_array([group1_latest_snapshot, group2_latest_snapshot])
    end
  end

  describe '.for_month' do
    it 'returns all snapshots where end_time equals given datetime end of month' do
      end_of_month = Time.zone.now.end_of_month
      snapshot1 = create(:devops_adoption_snapshot, end_time: end_of_month)
      create(:devops_adoption_snapshot, end_time: end_of_month - 1.year)

      expect(described_class.for_month(end_of_month)).to match_array([snapshot1])
      expect(described_class.for_month(end_of_month - 10.days)).to match_array([snapshot1])
      expect(described_class.for_month(end_of_month.beginning_of_month)).to match_array([snapshot1])
    end
  end

  describe '.not_finalized' do
    it 'returns all snapshots which were recorded earlier than snapshot end_time' do
      snapshot1 = create(:devops_adoption_snapshot, recorded_at: 1.day.ago, end_time: Time.zone.now)
      create(:devops_adoption_snapshot, recorded_at: 1.day.ago, end_time: 2.days.ago)

      expect(described_class.not_finalized).to match_array([snapshot1])
    end
  end

  describe '#start_time' do
    subject(:snapshot) { described_class.new(end_time: end_time) }

    let(:end_time) { DateTime.parse('2020-12-17') }
    let(:expected_start_time) { DateTime.parse('2020-12-01') }

    it 'is start of the month of end_time' do
      expect(snapshot.start_time).to eq(expected_start_time)
    end
  end
end
