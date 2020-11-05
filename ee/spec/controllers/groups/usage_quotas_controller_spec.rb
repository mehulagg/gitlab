# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Groups::UsageQuotasController do
  let_it_be(:group) { create(:group, :private) }
  let_it_be(:user) { create(:user) }

  before do
    sign_in(user)
    group.add_owner(user)
  end

  describe 'Pushing the `additionalRepoStorageByNamespace` feature flag to the frontend' do
    context 'when both flags are true' do
      before do
        stub_feature_flags(additional_repo_storage_by_namespace: true, namespace_storage_limit: true)
      end

      it 'is disabled' do
        get :index, params: { group_id: group }

        expect(Gon.features).to include('additionalRepoStorageByNamespace' => false)
      end
    end

    context 'when `namespace_storage_limit` flag is false' do
      before do
        stub_feature_flags(additional_repo_storage_by_namespace: true, namespace_storage_limit: false)
      end

      it 'is enabled' do
        get :index, params: { group_id: group }

        expect(Gon.features).to include('additionalRepoStorageByNamespace' => true)
      end
    end

    context 'when both flags are false' do
      before do
        stub_feature_flags(additional_repo_storage_by_namespace: false, namespace_storage_limit: false)
      end

      it 'is disabled' do
        get :index, params: { group_id: group }

        expect(Gon.features).to include('additionalRepoStorageByNamespace' => false)
      end
    end
  end
end
