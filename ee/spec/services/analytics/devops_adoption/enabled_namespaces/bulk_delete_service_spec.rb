# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Analytics::DevopsAdoption::EnabledNamespaces::BulkDeleteService do
  include AdminModeHelper

  let_it_be(:group) { create(:group) }
  let_it_be(:admin) { create(:user, :admin) }

  let(:enabled_namespace) { create(:devops_adoption_enabled_namespace, namespace: group) }
  let(:enabled_namespace2) { create(:devops_adoption_enabled_namespace) }
  let(:current_user) { admin }

  subject(:response) { described_class.new(enabled_namespaces: [enabled_namespace, enabled_namespace2], current_user: current_user).execute }

  before do
    enable_admin_mode!(admin)
    stub_licensed_features(group_level_devops_adoption: true, instance_level_devops_adoption: true)
  end

  it 'deletes the enabled_namespaces' do
    expect(response).to be_success
    expect(enabled_namespace).not_to be_persisted
    expect(enabled_namespace2).not_to be_persisted
  end

  context 'when deletion fails' do
    it 'keeps records and returns error response' do
      expect(enabled_namespace).to receive(:destroy).and_raise(ActiveRecord::RecordNotDestroyed)

      expect(response).to be_error
      expect(response.message).to eq('DevOps Adoption EnabledNamespace deletion error')
      expect(enabled_namespace).to be_persisted
      expect(enabled_namespace2).to be_persisted
    end
  end

  it 'authorizes for manage_devops_adoption' do
    expect(::Ability).to receive(:allowed?)
                           .with(current_user, :manage_devops_adoption_namespaces, group)
                           .at_least(1)
                           .and_return(true)
    expect(::Ability).to receive(:allowed?)
                           .with(current_user, :manage_devops_adoption_namespaces, enabled_namespace.display_namespace)
                           .at_least(1)
                           .and_return(true)
    expect(::Ability).to receive(:allowed?)
                           .with(current_user, :manage_devops_adoption_namespaces, enabled_namespace2.namespace)
                           .at_least(1)
                           .and_return(true)
    expect(::Ability).to receive(:allowed?)
                           .with(current_user, :manage_devops_adoption_namespaces, enabled_namespace2.display_namespace)
                           .at_least(1)
                           .and_return(true)

    response
  end
end
