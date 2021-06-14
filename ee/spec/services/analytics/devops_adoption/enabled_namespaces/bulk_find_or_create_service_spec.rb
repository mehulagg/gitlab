# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Analytics::DevopsAdoption::EnabledNamespaces::BulkFindOrCreateService do
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

  let_it_be(:enabled_namespace) { create :devops_adoption_enabled_namespace, namespace: group, display_namespace: display_group }

  let(:current_user) { reporter }
  let(:params) { { namespaces: [group, group2], display_namespace: display_group } }

  subject(:response) { described_class.new(params: params, current_user: current_user).execute }

  before do
    stub_licensed_features(group_level_devops_adoption: true, instance_level_devops_adoption: true)
  end

  it 'authorizes for manage_devops_adoption', :aggregate_failures do
    expect(::Ability).to receive(:allowed?)
                           .with(current_user, :manage_devops_adoption_namespaces, group)
                           .at_least(1)
                           .and_return(true)
    expect(::Ability).to receive(:allowed?)
                           .with(current_user, :manage_devops_adoption_namespaces, group2)
                           .at_least(1)
                           .and_return(true)
    expect(::Ability).to receive(:allowed?)
                           .with(current_user, :manage_devops_adoption_namespaces, display_group)
                           .at_least(2)
                           .and_return(true)

    response
  end

  context 'when the user cannot manage enabled_namespaces at least for one namespace' do
    let(:current_user) { create(:user).tap { |u| group.add_reporter(u) } }

    it 'returns forbidden error' do
      expect { response }.to raise_error(Analytics::DevopsAdoption::EnabledNamespaces::AuthorizationError)
    end
  end

  it 'returns existing enabled_namespaces for namespaces and creates new one if none exists' do
    expect { response }.to change { ::Analytics::DevopsAdoption::EnabledNamespace.count }.by(1)
    expect(response.payload.fetch(:enabled_namespaces)).to include(enabled_namespace)
  end
end
