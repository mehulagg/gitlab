# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Analytics::DevopsAdoption::Segments::DeleteService do
  let_it_be(:group) { create(:group) }
  let_it_be(:reporter) { create(:user).tap { |u| group.add_reporter(u) } }

  let(:segment) { create(:devops_adoption_segment, namespace: group) }
  let(:current_user) { reporter }

  subject(:response) { described_class.new(segment: segment, current_user: current_user).execute }

  it 'deletes the segment' do
    expect(response).to be_success
    expect(segment).not_to be_persisted
  end

  context 'when deletion fails' do
    it 'returns error response' do
      expect(segment).to receive(:destroy).and_raise(ActiveRecord::RecordNotDestroyed)

      expect(response).to be_error
      expect(response.message).to eq('DevOps Adoption Segment deletion error')
    end
  end

  it 'authorizes for manage_devops_adoption' do
    expect(::Ability).to receive(:allowed?).with(current_user, :manage_devops_adoption_segments, group).and_return true

    response
  end

  context 'when user cannot manage segments for the namespace' do
    let(:current_user) { create(:user) }

    it 'returns forbidden error' do
      expect { response }.to raise_error(Analytics::DevopsAdoption::Segments::AuthorizationError)
    end
  end
end
