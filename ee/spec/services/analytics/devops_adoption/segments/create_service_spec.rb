# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Analytics::DevopsAdoption::Segments::CreateService do
  let_it_be(:group) { create(:group) }

  let(:params) { { name: 'my service', group_ids: [group.id] } }

  subject { described_class.new(params: params).execute }

  it 'persists the segment' do
    expect(subject).to be_persisted
    expect(subject[:name]).to eq('my service')
    expect(subject.groups).to eq([group])
  end

  context 'when params are invalid' do
    before do
      params.delete(:name)
    end

    it 'does not persist the segment' do
      expect(subject).not_to be_persisted
      expect(subject.errors[:name]).not_to be_empty
    end
  end

  context 'when group_ids is not given' do
    before do
      params.delete(:group_ids)
    end

    it 'persists the segment without group_ids' do
      expect(subject).to be_persisted
    end
  end

  context 'when duplicated group_ids are given' do
    before do
      params[:group_ids] = [group.id] * 5
    end

    it 'persists the segments with unique group_ids' do
      expect(subject).to be_persisted
      expect(subject.groups).to eq([group])
    end
  end
end
