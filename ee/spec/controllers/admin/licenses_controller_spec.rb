# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Admin::LicensesController do
  let(:admin) { create(:admin) }

  before do
    sign_in(admin)
  end

  describe 'Upload license' do
    render_views

    it 'redirects back when no license is entered/uploaded' do
      post :create, params: { license: { data: '' } }
      expect(response).to redirect_to new_admin_license_path
      expect(flash[:alert]).to include 'Please enter or upload a license.'
    end

    it 'renders new with an alert when an invalid license is entered/uploaded' do
      post :create, params: { license: { data: 'GA!89-)GaRBAGE' } }

      expect(response).to render_template(:new)
      expect(response.body).to include('The license key is invalid. Make sure it is exactly as you received it from GitLab Inc.')
    end

    it 'redirects to show when a valid license is entered/uploaded' do
      gl_license = build(:gitlab_license, restrictions: {
                           trial: false,
                           plan: License::PREMIUM_PLAN,
                           active_user_count: 1,
                           previous_user_count: 1
                         })
      license = build(:license, data: gl_license.export)

      post :create, params: { license: { data: license.data } }

      expect(response).to redirect_to(admin_license_path)
    end

    context 'Trials' do
      before do
        stub_env('IN_MEMORY_APPLICATION_SETTINGS', 'false')
      end

      it 'redirects to show when a valid trial license is entered/uploaded' do
        gl_license = build(:gitlab_license,
                           expires_at: Date.tomorrow,
                           restrictions: {
                             trial: true,
                             plan: License::PREMIUM_PLAN,
                             active_user_count: 1,
                             previous_user_count: 1
                           })
        license = build(:license, data: gl_license.export)

        post :create, params: { license: { data: license.data } }

        expect(response).to redirect_to(admin_license_path)
      end
    end
  end

  describe 'GET show' do
    context 'with an existent license' do
      it 'renders the license details' do
        allow(License).to receive(:current).and_return(create(:license))

        get :show

        expect(response).to render_template(:show)
      end
    end

    context 'without a license' do
      it 'renders missing license page' do
        allow(License).to receive(:current).and_return(nil)

        get :show

        expect(response).to render_template(:missing)
      end
    end
  end
end
