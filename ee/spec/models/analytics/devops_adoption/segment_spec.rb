# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Analytics::DevopsAdoption::Segment, type: :model do
  describe 'associations' do
    subject { build(:devops_adoption_segment) }

    it { is_expected.to have_many(:snapshots) }
    it { is_expected.to belong_to(:namespace) }
    it { is_expected.to belong_to(:display_namespace) }
  end

  describe 'validation' do
    subject { build(:devops_adoption_segment) }

    it { is_expected.to validate_presence_of(:namespace) }
    it { is_expected.to validate_uniqueness_of(:namespace).scoped_to(:display_namespace_id) }
  end

  describe '.ordered_by_name' do
    subject(:segments) { described_class.ordered_by_name }

    it 'orders segments by namespace name' do
      segment_1 = create(:devops_adoption_segment, namespace: create(:group, name: 'bbb'))
      segment_2 = create(:devops_adoption_segment, namespace: create(:group, name: 'aaa'))

      expect(segments).to eq([segment_2, segment_1])
    end
  end

  describe '.for_namespaces' do
    subject(:segments) { described_class.for_namespaces(namespaces) }

    let_it_be(:segment1) { create(:devops_adoption_segment) }
    let_it_be(:segment2) { create(:devops_adoption_segment) }
    let_it_be(:segment3) { create(:devops_adoption_segment) }
    let_it_be(:namespaces) { [segment1.namespace, segment2.namespace]}

    it 'selects segments for given namespaces only' do
      expect(segments).to match_array([segment1, segment2])
    end
  end

  describe '.for_parent' do
    let_it_be(:group) { create :group }
    let_it_be(:subgroup) { create :group, parent: group }
    let_it_be(:group2) { create :group }

    let_it_be(:segment1) { create(:devops_adoption_segment, namespace: group) }
    let_it_be(:segment2) { create(:devops_adoption_segment, namespace: subgroup) }
    let_it_be(:segment3) { create(:devops_adoption_segment, namespace: group2) }

    subject(:segments) { described_class.for_parent(group) }

    it 'selects segments for given namespace only' do
      expect(segments).to match_array([segment1, segment2])
    end
  end

  describe '.latest_snapshot' do
    it 'loads the latest snapshot' do
      segment = create(:devops_adoption_segment)
      latest_snapshot = create(:devops_adoption_snapshot, namespace: segment.namespace, end_time: 2.days.ago)
      create(:devops_adoption_snapshot, namespace: segment.namespace, end_time: 5.days.ago)
      create(:devops_adoption_snapshot, end_time: 1.hour.ago)

      expect(segment.latest_snapshot).to eq(latest_snapshot)
    end
  end
end
