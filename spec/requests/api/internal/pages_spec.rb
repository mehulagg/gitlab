# frozen_string_literal: true

require 'spec_helper'

describe API::Internal::Pages do
  describe "GET /internal/pages" do
    let(:pages_shared_secret) { SecureRandom.random_bytes(Gitlab::Pages::SECRET_LENGTH) }

    before do
      allow(Gitlab::Pages).to receive(:secret).and_return(pages_shared_secret)
    end

    def query_host(host, headers = {})
      get api("/internal/pages"), headers: headers, params: { host: host }
    end

    context 'feature flag disabled' do
      before do
        stub_feature_flags(pages_internal_api: false)
      end

      it 'responds with 404 Not Found' do
        query_host('pages.gitlab.io')

        expect(response).to have_gitlab_http_status(404)
      end
    end

    context 'feature flag enabled' do
      context 'not authenticated' do
        it 'responds with 401 Unauthorized' do
          query_host('pages.gitlab.io')

          expect(response).to have_gitlab_http_status(401)
        end
      end

      context 'authenticated' do
        def query_host(host)
          jwt_token = JWT.encode({ 'iss' => 'gitlab-pages' }, Gitlab::Pages.secret, 'HS256')
          headers = { Gitlab::Pages::INTERNAL_API_REQUEST_HEADER => jwt_token }

          super(host, headers)
        end

        it 'responds with 200 OK' do
          query_host('pages.gitlab.io')

          expect(response).to have_gitlab_http_status(200)
        end
      end
    end
  end
end
