# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Analytics::DevopsAdoption::Segments::FindOrCreateService do
  let_it_be(:group) { create(:group) }
  let_it_be(:display_group) { create(:group) }

  let_it_be(:reporter) do
    create(:user).tap do |u|
      group.add_reporter(u)
      display_group.add_reporter(u)
    end
  end

  let(:current_user) { reporter }

  let(:params) { { namespace: group, display_namespace: display_group } }

  subject(:response) { described_class.new(params: params, current_user: current_user).execute }

  before do
    stub_licensed_features(group_level_devops_adoption: true, instance_level_devops_adoption: true)
  end

  context 'when segment for given namespace & display_namespace already exists' do
    let!(:segment) { create :devops_adoption_segment, namespace: group, display_namespace: display_group }

    it 'returns existing segment' do
      expect { response }.not_to change { Analytics::DevopsAdoption::Segment.count }

      expect(subject.payload.fetch(:segment)).to eq(segment)
    end
  end

  context 'when segment for given namespace does not exist' do
    let!(:segment2) { create :devops_adoption_segment, namespace: group }
    let!(:segment3) { create :devops_adoption_segment, display_namespace: display_group }

    it 'calls for segment creation' do
      expect_next_instance_of(Analytics::DevopsAdoption::Segments::CreateService,
                              current_user: current_user,
                              params: { namespace: group, display_namespace: display_group }) do |instance|
        expect(instance).to receive(:execute).and_return('create_response')
      end

      expect(response).to eq 'create_response'
    end
  end

  it 'authorizes for manage_devops_adoption' do
    expect(::Ability).to receive(:allowed?)
                           .with(current_user, :manage_devops_adoption_segments, group)
                           .at_least(1)
                           .and_return(true)

    expect(::Ability).to receive(:allowed?)
                           .with(current_user, :manage_devops_adoption_segments, display_group)
                           .at_least(1)
                           .and_return(true)

    response
  end

  context 'when user cannot manage devops adoption for given namespace' do
    let(:current_user) { create(:user) }

    it 'returns forbidden error' do
      expect { response }.to raise_error(Analytics::DevopsAdoption::Segments::AuthorizationError)
    end
  end
end
