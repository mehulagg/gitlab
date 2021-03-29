# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Admin::CloudLicensesController, :cloud_licenses do
  include AdminModeHelper

  describe 'GET /cloud_licenses' do
    context 'when the user is not admin' do
      let_it_be(:user) { create(:user) }

      it 'responds with 404' do
        sign_in(user)

        send_request

        expect(response).to have_gitlab_http_status(:not_found)
      end
    end

    context 'when the user an admin' do
      let_it_be(:admin) { create(:admin) }

      before do
        login_as(admin)
        enable_admin_mode!(admin)
      end

      context 'when the application setting is not active' do
        before do
          stub_application_setting(cloud_license_enabled: false)
        end

        it 'redirects to admin license path when the setting is not active' do
          send_request

          expect(response).to redirect_to admin_license_path
        end
      end

      context 'when the application setting is active' do
        before do
          stub_application_setting(cloud_license_enabled: true)
        end

        it 'renders the Activation Form' do
          send_request

          expect(response).to render_template(:show)
          expect(response.body).to include('js-show-cloud-license-page')
        end
      end
    end
  end

  def send_request
    get admin_cloud_license_path
  end
end
