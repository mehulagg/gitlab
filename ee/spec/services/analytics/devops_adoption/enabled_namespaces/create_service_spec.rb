# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Analytics::DevopsAdoption::EnabledNamespaces::CreateService do
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
  let(:enabled_namespace) { subject.payload[:enabled_namespace] }

  subject(:response) { described_class.new(params: params, current_user: current_user).execute }

  before do
    stub_licensed_features(group_level_devops_adoption: true, instance_level_devops_adoption: true)
  end

  it 'persists the enabled_namespace', :aggregate_failures do
    expect(response).to be_success
    expect(enabled_namespace.namespace).to eq(group)
    expect(enabled_namespace.display_namespace).to eq(display_group)
  end

  it 'schedules for snapshot creation' do
    allow(Analytics::DevopsAdoption::CreateSnapshotWorker).to receive(:perform_async).and_call_original

    response

    expect(Analytics::DevopsAdoption::CreateSnapshotWorker).to have_received(:perform_async).with(Analytics::DevopsAdoption::EnabledNamespace.last.id)
  end

  it 'authorizes for manage_devops_adoption', :aggregate_failures do
    expect(::Ability).to receive(:allowed?).with(current_user, :manage_devops_adoption_namespaces, group).and_return true
    expect(::Ability).to receive(:allowed?).with(current_user, :manage_devops_adoption_namespaces, display_group).and_return true

    response
  end

  context 'without display_namespace_id' do
    before do
      params[:display_namespace] = nil
    end

    it 'authorizes for global manage_devops_adoption', :aggregate_failures do
      expect(::Ability).to receive(:allowed?).with(current_user, :manage_devops_adoption_namespaces, group).and_return true
      expect(::Ability).to receive(:allowed?).with(current_user, :manage_devops_adoption_namespaces, :global).and_return true

      response
    end
  end

  context 'for guests' do
    let(:current_user) { create(:user) }

    it 'returns forbidden error' do
      expect { response }.to raise_error(Analytics::DevopsAdoption::EnabledNamespaces::AuthorizationError)
    end
  end
end
