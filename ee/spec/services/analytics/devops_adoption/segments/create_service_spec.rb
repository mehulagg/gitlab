# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Analytics::DevopsAdoption::Segments::CreateService do
  let_it_be(:group) { create(:group) }
  let_it_be(:reporter) { create(:user).tap { |u| group.add_reporter(u) } }

  let(:current_user) { reporter }

  let(:params) { { namespace: group } }
  let(:segment) { subject.payload[:segment] }

  subject(:response) { described_class.new(params: params, current_user: current_user).execute }

  it 'persists the segment' do
    expect(response).to be_success
    expect(segment.namespace).to eq(group)
  end

  it 'schedules for snapshot creation' do
    allow(Analytics::DevopsAdoption::CreateSnapshotWorker).to receive(:perform_async).and_call_original

    response

    expect(Analytics::DevopsAdoption::CreateSnapshotWorker).to have_received(:perform_async).with(Analytics::DevopsAdoption::Segment.last.id)
  end

  it 'authorizes for manage_devops_adoption' do
    expect(::Ability).to receive(:allowed?).with(current_user, :manage_devops_adoption_segments, group).and_return true

    response
  end

  context 'for guests' do
    let(:current_user) { create(:user) }

    it 'returns forbidden error' do
      expect { response }.to raise_error(Analytics::DevopsAdoption::Segments::AuthorizationError)
    end
  end
end
