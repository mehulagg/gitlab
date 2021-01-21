# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Analytics::DevopsAdoption::Segments::CreateService do
  include AdminModeHelper

  let_it_be(:admin) { create(:user, :admin) }
  let_it_be(:group) { create(:group) }

  let(:params) { { namespace: group } }
  let(:segment) { subject.payload[:segment] }

  subject { described_class.new(params: params, current_user: admin).execute }

  before do
    enable_admin_mode!(admin)
  end

  it 'persists the segment' do
    expect(subject).to be_success
    expect(segment.namespace).to eq(group)
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

  context 'when namespace is not given' do
    before do
      params.delete(:namespace)
    end

    it "doesn't save the segment" do
      expect(subject).to be_error
      expect(subject.message).to eq('Validation error')
      expect(segment.namespace).to be_nil
    end
  end
end
