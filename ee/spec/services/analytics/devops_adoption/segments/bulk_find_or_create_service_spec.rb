# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Analytics::DevopsAdoption::Segments::BulkFindOrCreateService do
  let_it_be(:group) { create(:group) }
  let_it_be(:group2) { create(:group) }
  let_it_be(:display_group) { create(:group) }

  let_it_be(:reporter) do
    create(:user).tap do |u|
      group.add_reporter(u)
      group2.add_reporter(u)
      display_group.add_reporter(u)
    end
  end

  let_it_be(:segment) { create :devops_adoption_segment, namespace: group, display_namespace: display_group }

  let(:current_user) { reporter }
  let(:params) { { namespaces: [group, group2], display_namespace: display_group } }

  subject(:response) { described_class.new(params: params, current_user: current_user).execute }

  before do
    stub_licensed_features(group_level_devops_adoption: true, instance_level_devops_adoption: true)
  end

  it 'authorizes for manage_devops_adoption', :aggregate_failures do
    expect(::Ability).to receive(:allowed?)
                           .with(current_user, :manage_devops_adoption_segments, group)
                           .at_least(1)
                           .and_return(true)
    expect(::Ability).to receive(:allowed?)
                           .with(current_user, :manage_devops_adoption_segments, group2)
                           .at_least(1)
                           .and_return(true)
    expect(::Ability).to receive(:allowed?)
                           .with(current_user, :manage_devops_adoption_segments, display_group)
                           .at_least(2)
                           .and_return(true)

    response
  end

  context 'when the user cannot manage segments at least for one namespace' do
    let(:current_user) { create(:user).tap { |u| group.add_reporter(u) } }

    it 'returns forbidden error' do
      expect { response }.to raise_error(Analytics::DevopsAdoption::Segments::AuthorizationError)
    end
  end

  it 'returns existing segments for namespaces and creates new one if none exists' do
    expect { response }.to change { ::Analytics::DevopsAdoption::Segment.count }.by(1)
    expect(response.payload.fetch(:segments)).to include(segment)
  end
end
