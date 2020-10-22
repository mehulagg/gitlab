# frozen_string_literal: true

require 'spec_helper'

RSpec.describe UsernamesController do
  describe 'GET #suggest' do
    context 'namespace does not exist' do
      it 'returns JSON with the suggested username' do
        get :suggest, params: { name: 'Arthur' }

        expected_json = { username: 'arthur' }.to_json
        expect(response.body).to eq(expected_json)
      end
    end

    context 'namespace exists' do
      before do
        create(:user, name: 'disney')
      end

      it 'returns JSON with the parameterized username and suffix as a suggestion' do
        get :suggest, params: { name: 'Disney' }

        expected_json = { username: 'disney1' }.to_json
        expect(response.body).to eq(expected_json)
      end
    end

    context 'no name provided' do
      it 'returns bad request response' do
        get :suggest

        expect(response).to have_gitlab_http_status(:bad_request)
      end
    end
  end
end
