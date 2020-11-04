# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Analytics::DevopsAdoption::Segment, type: :model do
  subject { build(:devops_adoption_segment) }

  describe 'validation' do
    it { is_expected.to validate_presence_of(:name) }
    it { is_expected.to validate_uniqueness_of(:name) }
    it { is_expected.to validate_length_of(:name).is_at_most(255) }

    context 'limit the number of segments' do
      subject { build(:devops_adoption_segment) }

      before do
        create_list(:devops_adoption_segment, 2)

        stub_const("#{described_class}::ALLOWED_SEGMENT_COUNT", 2)
      end

      it 'shows validation error' do
        subject.validate

        expect(subject.errors[:name]).to eq([s_('DevopsAdoptionSegment|The maximum number of segments has been reached')])
      end
    end
  end

  describe '.ordered_by_name' do
    let(:segment_1) { create(:devops_adoption_segment, name: 'bbb') }
    let(:segment_2) { create(:devops_adoption_segment, name: 'aaa') }

    subject { described_class.ordered_by_name }

    it 'orders segments by name' do
      expect(subject).to eq([segment_2, segment_1])
    end
  end
end
