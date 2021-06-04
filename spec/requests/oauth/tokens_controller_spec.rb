# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Oauth::TokensController do
  let(:cors_request_headers) { { 'Origin' => 'http://notgitlab.com' } }

  shared_examples 'cross-origin POST request' do
    it 'allows cross-origin requests' do
      expect(response.headers['Access-Control-Allow-Origin']).to eq '*'
      expect(response.headers['Access-Control-Allow-Methods']).to eq 'POST'
      expect(response.headers['Access-Control-Allow-Headers']).to be_nil
      expect(response.headers['Access-Control-Allow-Credentials']).to be_nil
    end
  end

  describe '/oauth/token' do
    before do
      post '/oauth/token', headers: cors_request_headers
    end

    it_behaves_like 'cross-origin POST request'
  end

  describe '/oauth/revoke' do
    before do
      post '/oauth/revoke', headers: cors_request_headers
    end

    it_behaves_like 'cross-origin POST request'
  end
end
