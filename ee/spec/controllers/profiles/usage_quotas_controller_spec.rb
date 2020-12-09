# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Profiles::UsageQuotasController do
  let_it_be(:user) { create(:user) }

  before do
    sign_in(user)
  end

  describe 'GET index' do
    it 'renders usage quota page' do
      get :index

      expect(subject).to render_template(:index)
    end
  end

  describe 'Pushing the `additionalRepoStorageByNamespace` feature flag to the frontend' do
    before do
      allow_next_found_instance_of(Namespace) do |namespace|
        allow(namespace).to receive(:additional_repo_storage_by_namespace_enabled?)
          .and_return(additional_repo_storage_by_namespace_enabled)
      end
    end

    context 'when additional_repo_storage_by_namespace_enabled is false' do
      let(:additional_repo_storage_by_namespace_enabled) { false }

      it 'is disabled' do
        get :index

        expect(Gon.features).to include('additionalRepoStorageByNamespace' => false)
      end
    end

    context 'when additional_repo_storage_by_namespace_enabled is true' do
      let(:additional_repo_storage_by_namespace_enabled) { true }

      it 'is enabled' do
        get :index

        expect(Gon.features).to include('additionalRepoStorageByNamespace' => true)
      end
    end
  end
end
