# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Groups::DependencyProxyForContainersController do
  let(:group) { create(:group) }
  let(:token_response) { { status: :success, token: 'abcd1234' } }

  before do
    allow(Gitlab.config.dependency_proxy)
      .to receive(:enabled).and_return(true)

    allow_next_instance_of(DependencyProxy::RequestTokenService) do |instance|
      allow(instance).to receive(:execute).and_return(token_response)
    end
  end

  describe 'GET #manifest' do
    let(:manifest) { { foo: 'bar' }.to_json }
    let(:pull_response) { { status: :success, manifest: manifest } }

    before do
      allow_next_instance_of(DependencyProxy::PullManifestService) do |instance|
        allow(instance).to receive(:execute).and_return(pull_response)
      end
    end

    context 'feature enabled' do
      before do
        enable_dependency_proxy
      end

      context 'remote token request fails' do
        let(:token_response) do
          {
            status: :error,
            http_status: 503,
            message: 'Service Unavailable'
          }
        end

        it 'proxies status from the remote token request' do
          get_manifest

          expect(response).to have_gitlab_http_status(:service_unavailable)
          expect(response.body).to eq('Service Unavailable')
        end
      end

      context 'remote manifest request fails' do
        let(:pull_response) do
          {
            status: :error,
            http_status: 400,
            message: ''
          }
        end

        it 'proxies status from the remote manifest request' do
          get_manifest

          expect(response).to have_gitlab_http_status(:bad_request)
          expect(response.body).to be_empty
        end
      end

      it 'returns 200 with manifest file' do
        get_manifest

        expect(response).to have_gitlab_http_status(:ok)
        expect(response.body).to eq(manifest)
      end
    end

    it 'returns 404 when feature is disabled' do
      get_manifest

      expect(response).to have_gitlab_http_status(:not_found)
    end

    def get_manifest
      get :manifest, params: { group_id: group.to_param, image: 'alpine', tag: '3.9.2' }
    end
  end

  describe 'GET #blob' do
    let(:blob) { create(:dependency_proxy_blob) }
    let(:blob_sha) { blob.file_name.sub('.gz', '') }
    let(:blob_response) { { status: :success, blob: blob } }

    before do
      allow_next_instance_of(DependencyProxy::FindOrCreateBlobService) do |instance|
        allow(instance).to receive(:execute).and_return(blob_response)
      end
    end

    context 'feature enabled' do
      before do
        enable_dependency_proxy
      end

      context 'remote blob request fails' do
        let(:blob_response) do
          {
            status: :error,
            http_status: 400,
            message: ''
          }
        end

        it 'proxies status from the remote blob request' do
          get_blob

          expect(response).to have_gitlab_http_status(:bad_request)
          expect(response.body).to be_empty
        end
      end

      it 'sends a file' do
        expect(controller).to receive(:send_file).with(blob.file.path, {})

        get_blob
      end

      it 'returns Content-Disposition: attachment' do
        get_blob

        expect(response).to have_gitlab_http_status(:ok)
        expect(response.headers['Content-Disposition']).to match(/^attachment/)
      end
    end

    it 'returns 404 when feature is disabled' do
      get_blob

      expect(response).to have_gitlab_http_status(:not_found)
    end

    def get_blob
      get :blob, params: { group_id: group.to_param, image: 'alpine', sha: blob_sha }
    end
  end

  def enable_dependency_proxy
    stub_licensed_features(dependency_proxy: true)
    group.create_dependency_proxy_setting!(enabled: true)
  end
end
