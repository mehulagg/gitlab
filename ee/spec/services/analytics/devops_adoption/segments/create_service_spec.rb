# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Analytics::DevopsAdoption::Segments::CreateService do
  include AdminModeHelper

  let_it_be(:admin) { create(:user, :admin) }
  let_it_be(:group) { create(:group) }

  let(:params) { { name: 'my service', groups: [group] } }
  let(:segment) { subject.payload[:segment] }

  subject { described_class.new(params: params, current_user: admin).execute }

  before do
    enable_admin_mode!(admin)
  end

  it 'persists the segment' do
    expect(subject).to be_success
    expect(segment.name).to eq('my service')
    expect(segment.groups).to eq([group])
  end

  it 'schedules for snapshot creation' do
    allow(Analytics::DevopsAdoption::CreateSnapshotWorker).to receive(:perform_async).and_call_original

    subject

    expect(Analytics::DevopsAdoption::CreateSnapshotWorker).to have_received(:perform_async).with(Analytics::DevopsAdoption::Segment.last.id, nil)
  end

  context 'when user is not an admin' do
    let(:user) { build(:user) }

    subject { described_class.new(params: params, current_user: user).execute }

    it 'does not persist the segment' do
      expect(subject).to be_error
      expect(subject.message).to eq('Forbidden')
      expect(segment).not_to be_persisted
    end
  end

  context 'when params are invalid' do
    before do
      params.delete(:name)
    end

    it 'does not persist the segment' do
      expect(subject).to be_error
      expect(segment.errors[:name]).not_to be_empty
    end
  end

  context 'when groups are not given' do
    before do
      params.delete(:groups)
    end

    it 'persists the segment without groups' do
      expect(subject).to be_success
      expect(segment.segment_selections).to be_empty
    end
  end

  context 'when duplicated groups are given' do
    before do
      params[:groups] = [group] * 5
    end

    it 'persists the segments with unique groups' do
      expect(subject).to be_success
      expect(segment.groups).to eq([group])
    end
  end
end
