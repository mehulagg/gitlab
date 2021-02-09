# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Groups::UsageQuotasController do
  let_it_be(:group) { create(:group, :private) }
  let_it_be(:user) { create(:user) }

  before do
    sign_in(user)
    group.add_owner(user)

    allow_next_found_instance_of(Group) do |group|
      allow(group).to receive(:additional_repo_storage_by_namespace_enabled?)
        .and_return(additional_repo_storage_by_namespace_enabled)
    end
  end

  describe 'Pushing the `additionalRepoStorageByNamespace` feature flag to the frontend' do
    context 'when additional_repo_storage_by_namespace_enabled is false' do
      let(:additional_repo_storage_by_namespace_enabled) { false }

      it 'is disabled' do
        get :index, params: { group_id: group }

        expect(Gon.features).to include('additionalRepoStorageByNamespace' => false)
      end
    end

    context 'when additional_repo_storage_by_namespace_enabled is true' do
      let(:additional_repo_storage_by_namespace_enabled) { true }

      it 'is enabled' do
        get :index, params: { group_id: group }

        expect(Gon.features).to include('additionalRepoStorageByNamespace' => true)
      end
    end
  end
end
