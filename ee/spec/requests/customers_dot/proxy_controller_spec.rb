# frozen_string_literal: true

require 'spec_helper'

RSpec.describe CustomersDot::ProxyController, type: :request do
  describe 'POST graphql' do
    let_it_be(:customers_dot) { described_class::CUSTOMERS_GRAPHQL_URL }
    let_it_be(:base_headers)  { { 'Content-Type' => 'application/json' } }

    let_it_be(:request_params) do
      {
        "query" => "foo",
        "variables" => "bar"
      }
    end

    before do
      stub_request(:post, customers_dot)
    end

    shared_examples 'customersdot proxy' do
      it 'responds with customers dot status' do
        stub_request(:post, customers_dot).to_return(status: 500)

        post_proxy(request_params)

        expect(response).to have_gitlab_http_status(:internal_server_error)
      end

      it 'responds with customers dot response body' do
        customers_dot_response = 'foo'

        stub_request(:post, customers_dot).to_return(body: customers_dot_response)

        post_proxy(request_params)

        expect(response.body).to eq(customers_dot_response)
      end
    end

    context 'with logged in gitlab user' do
      let_it_be(:user) { create(:user) }
      let_it_be(:expected_customersdot_params) do
        request_params.merge( { gitlab_user_id: user.id } )
      end

      before do
        login_as(user)
      end

      it 'forwards request with user id' do
        post_proxy(request_params)

        expect(WebMock).to have_requested(:post, customers_dot).with(body: expected_customersdot_params)
      end

      it 'adds admin headers' do
        expected_headers = base_headers.merge(
          'X-Admin-Email' => EE::SUBSCRIPTION_PORTAL_ADMIN_EMAIL,
          'X-Admin-Token' => EE::SUBSCRIPTION_PORTAL_ADMIN_TOKEN
        )

        post_proxy(request_params)

        expect(WebMock).to have_requested(:post, customers_dot).with(headers: expected_headers)
      end

      it 'ignores passed in gitlab_user_id' do
        post_proxy(request_params.merge(gitlab_user_id: 'foo'))

        expect(WebMock).to have_requested(:post, customers_dot).with(body: expected_customersdot_params)
      end

      it_behaves_like 'customersdot proxy'
    end

    context 'with no gitlab user logged in' do
      it 'forwards request to customers dot' do
        post_proxy(request_params)

        expect(WebMock).to have_requested(:post, customers_dot).with(body: request_params)
      end

      it 'does not attach admin headers' do
        post_proxy(request_params)

        expect(WebMock).to have_requested(:post, customers_dot).with(headers: base_headers)
      end

      it 'ignores passed in gitlab_user_id' do
        post_proxy(request_params.merge(gitlab_user_id: 'foo'))

        expect(WebMock).to have_requested(:post, customers_dot).with(body: request_params)
      end

      it_behaves_like 'customersdot proxy'
    end
  end

  def post_proxy(params)
    post customers_dot_proxy_graphql_path, params: params, as: :json
  end
end
