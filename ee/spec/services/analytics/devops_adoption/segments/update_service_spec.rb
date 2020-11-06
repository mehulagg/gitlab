# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Analytics::DevopsAdoption::Segments::UpdateService do
  let_it_be(:group) { create(:group) }
  let_it_be(:other_group) { create(:group) }
  let_it_be_with_refind(:segment) { create(:devops_adoption_segment, name: 'segment', segment_selections: [build(:devops_adoption_segment_selection, :group, group: group)]) }

  let(:params) { { name: 'new name', groups: [group, other_group] } }

  subject { described_class.new(segment: segment, params: params).execute }

  it 'persists the segment' do
    expect(subject).to be_valid
    expect(subject[:name]).to eq('new name')
    expect(subject.groups).to eq([group, other_group])
  end

  context 'when params are invalid' do
    before do
      params[:name] = ''
    end

    it 'does not persist the segment' do
      expect(subject).not_to be_valid
      expect(subject.errors[:name]).not_to be_empty
    end
  end

  context 'when groups are not given' do
    before do
      params.delete(:groups)
    end

    it 'does not change the groups' do
      expect(subject).to be_valid
      expect(subject.groups).to eq([group])
    end
  end
end
