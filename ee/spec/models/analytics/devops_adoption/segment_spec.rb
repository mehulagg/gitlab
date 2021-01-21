# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Analytics::DevopsAdoption::Segment, type: :model do
  describe 'associations' do
    subject { build(:devops_adoption_segment) }

    it { is_expected.to have_many(:segment_selections) }
    it { is_expected.to have_many(:groups) }
    it { is_expected.to have_many(:snapshots) }
  end

  describe 'validation' do
    subject { build(:devops_adoption_segment) }

    it { is_expected.to validate_presence_of(:name) }
    it { is_expected.to validate_uniqueness_of(:name) }
    it { is_expected.to validate_length_of(:name).is_at_most(255) }

    context 'limit the number of segments' do
      subject(:segment) { build(:devops_adoption_segment) }

      it 'shows validation error' do
        create_list(:devops_adoption_segment, 2)
        stub_const("#{described_class}::ALLOWED_SEGMENT_COUNT", 2)

        segment.validate

        expect(segment.errors[:name]).to eq([s_('DevopsAdoptionSegment|The maximum number of segments has been reached')])
      end
    end
  end

  describe '.ordered_by_name' do
    subject(:segments) { described_class.ordered_by_name }

    it 'orders segments by name' do
      segment_1 = create(:devops_adoption_segment, name: 'bbb')
      segment_2 = create(:devops_adoption_segment, name: 'aaa')

      expect(segments).to eq([segment_2, segment_1])
    end
  end

  describe '.latest_snapshot' do
    it 'loads the latest snapshot' do
      segment = create(:devops_adoption_segment, name: 'test_segment')
      latest_snapshot = create(:devops_adoption_snapshot, segment: segment, recorded_at: 2.days.ago)
      create(:devops_adoption_snapshot, segment: segment, recorded_at: 5.days.ago)
      create(:devops_adoption_snapshot, segment: create(:devops_adoption_segment), recorded_at: 1.hour.ago)

      expect(segment.latest_snapshot).to eq(latest_snapshot)
    end
  end

  describe 'length validation on accepts_nested_attributes_for for segment_selections' do
    it 'validates the number of segment_selections' do
      stub_const("Analytics::DevopsAdoption::SegmentSelection::ALLOWED_SELECTIONS_PER_SEGMENT", 1)

      group_1 = create(:group)
      group_2 = create(:group)
      segment = create(:devops_adoption_segment, segment_selections_attributes: [{ group: group_1 }])
      selections = [{ group: group_1, _destroy: 1 }, { group: group_2 }]

      segment.assign_attributes(segment_selections_attributes: selections)

      expect(segment).to be_invalid
      expect(segment.errors[:"segment_selections.segment"]).to eq([s_('DevopsAdoptionSegmentSelection|The maximum number of selections has been reached')])
    end
  end
end
