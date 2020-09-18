# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Import::V2::GitlabGroupsController do
  let(:user) { create(:user) }

  before do
    sign_in(user)
  end

  context 'when group_import_v2 feature flag is enabled' do
    before do
      stub_feature_flags(group_import_v2: true)
    end

    describe 'POST configure' do
      let(:token) { 'token' }
      let(:url) { 'https://gitlab.example' }

      context 'when no params are passed in' do
        it 'clears out existing session' do
          post :configure

          expect(session[:gitlab_personal_access_token]).to be_nil
          expect(session[:gitlab_url]).to be_nil

          expect(response).to have_gitlab_http_status(:found)
          expect(response).to redirect_to(status_import_v2_gitlab_group_url)
        end
      end

      it 'sets the session variables' do
        post :configure, params: { gitlab_personal_access_token: token, gitlab_url: url }

        expect(session[:gitlab_personal_access_token]).to eq(token)
        expect(session[:gitlab_url]).to eq(url)
        expect(response).to have_gitlab_http_status(:found)
        expect(response).to redirect_to(status_import_v2_gitlab_group_url)
      end

      it 'strips access token with spaces' do
        post :configure, params: { gitlab_personal_access_token: "  #{token} " }

        expect(session[:gitlab_personal_access_token]).to eq(token)
        expect(controller).to redirect_to(status_import_v2_gitlab_group_url)
      end
    end

    describe 'GET status' do
      context 'when host url is local or not http' do
        %w[https://localhost:3000 http://192.168.0.1 ftp://testing].each do |url|
          before do
            allow(controller).to receive(:allow_local_requests?).and_return(false)

            session[:gitlab_personal_access_token] = 'test'
            session[:gitlab_url] = url
          end

          it 'denies network request' do
            get :status

            expect(controller).to redirect_to(new_group_path)
            expect(flash[:alert]).to eq('Specified URL cannot be used: "Only allowed schemes are http, https"')
          end
        end
      end
    end
  end

  context 'when group_import_v2 feature flag is disabled' do
    before do
      stub_feature_flags(group_import_v2: false)
    end

    context 'POST configure' do
      it 'returns 404' do
        post :configure

        expect(response).to have_gitlab_http_status(:not_found)
      end
    end

    context 'GET status' do
      it 'returns 404' do
        get :status

        expect(response).to have_gitlab_http_status(:not_found)
      end
    end
  end
end
