# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Analytics::DevopsAdoption::EnabledNamespaces::DeleteService do
  let_it_be(:group) { create(:group) }
  let_it_be(:display_group) { create(:group) }

  let_it_be(:reporter) do
    create(:user).tap do |u|
      group.add_reporter(u)
      display_group.add_reporter(u)
    end
  end

  let(:enabled_namespace) { create(:devops_adoption_enabled_namespace, namespace: group, display_namespace: display_group) }
  let(:current_user) { reporter }

  subject(:response) { described_class.new(enabled_namespace: enabled_namespace, current_user: current_user).execute }

  before do
    stub_licensed_features(group_level_devops_adoption: true, instance_level_devops_adoption: true)
  end

  it 'deletes the enabled_namespace' do
    expect(response).to be_success
    expect(enabled_namespace).not_to be_persisted
  end

  context 'when deletion fails' do
    it 'returns error response' do
      expect(enabled_namespace).to receive(:destroy).and_raise(ActiveRecord::RecordNotDestroyed)

      expect(response).to be_error
      expect(response.message).to eq('DevOps Adoption EnabledNamespace deletion error')
    end
  end

  it 'authorizes for manage_devops_adoption', :aggregate_failures do
    expect(::Ability).to receive(:allowed?).with(current_user, :manage_devops_adoption_namespaces, group).and_return true
    expect(::Ability).to receive(:allowed?).with(current_user, :manage_devops_adoption_namespaces, display_group).and_return true

    response
  end

  context 'when user cannot manage enabled_namespaces for the namespace' do
    let(:current_user) { create(:user) }

    it 'returns forbidden error' do
      expect { response }.to raise_error(Analytics::DevopsAdoption::EnabledNamespaces::AuthorizationError)
    end
  end
end
