# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Analytics::DevopsAdoption::Segments::CreateService do
  include AdminModeHelper

  let_it_be(:user) { create(:user, :admin) }
  let_it_be(:group) { create(:group) }

  let(:params) { { namespace: group } }
  let(:segment) { subject.payload[:segment] }

  subject { described_class.new(params: params, current_user: user).execute }

  before do
    enable_admin_mode!(user)
  end

  it 'persists the segment' do
    expect(subject).to be_success
    expect(segment.namespace).to eq(group)
  end

  it 'schedules for snapshot creation' do
    allow(Analytics::DevopsAdoption::CreateSnapshotWorker).to receive(:perform_async).and_call_original

    subject

    expect(Analytics::DevopsAdoption::CreateSnapshotWorker).to have_received(:perform_async).with(Analytics::DevopsAdoption::Segment.last.id)
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

  context 'for non-admins' do
    let_it_be(:user) { build(:user) }

    it 'returns forbidden error' do
      expect do
        subject
      end.to raise_error(Analytics::DevopsAdoption::Segments::AuthorizationError)
    end
  end
end
