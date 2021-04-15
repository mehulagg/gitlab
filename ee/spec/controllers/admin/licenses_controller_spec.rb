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
      expect do
        post :create, params: { license: { data: '' } }
      end.not_to change(License, :count)

      expect(response).to redirect_to new_admin_license_path
      expect(flash[:alert]).to include 'Please enter or upload a valid license.'
    end

    context 'when the license is for a cloud license' do
      it 'redirects back' do
        license = build_license(type: 'cloud')

        expect do
          post :create, params: { license: { data: license.data } }
        end.not_to change(License, :count)

        expect(response).to redirect_to new_admin_license_path
        expect(flash[:alert]).to include 'Please enter or upload a valid license.'
      end
    end

    it 'renders new with an alert when an invalid license is entered/uploaded' do
      expect do
        post :create, params: { license: { data: 'GA!89-)GaRBAGE' } }
      end.not_to change(License, :count)

      expect(response).to render_template(:new)
      expect(response.body).to include('The license key is invalid. Make sure it is exactly as you received it from GitLab Inc.')
    end

    it 'redirects to show when a valid license is entered/uploaded' do
      license = build_license

      expect do
        post :create, params: { license: { data: license.data } }
      end.to change(License, :count).by(1)

      expect(response).to redirect_to(admin_license_path)
    end

    context 'Trials' do
      before do
        stub_env('IN_MEMORY_APPLICATION_SETTINGS', 'false')
      end

      it 'redirects to show when a valid trial license is entered/uploaded' do
        license = build_license(restrictions: { trial: true })

        expect do
          post :create, params: { license: { data: license.data } }
        end.to change(License, :count).by(1)

        expect(response).to redirect_to(admin_license_path)
      end
    end

    def build_license(type: nil, restrictions: {})
      license_restrictions = {
        trial: false,
        plan: License::PREMIUM_PLAN,
        active_user_count: 1,
        previous_user_count: 1
      }.merge(restrictions)
      gl_license = build(:gitlab_license, type: type, restrictions: license_restrictions)

      build(:license, data: gl_license.export)
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

  describe 'POST sync_seat_link' do
    let_it_be(:historical_data) { create(:historical_data, recorded_at: Time.current) }

    before do
      allow(License).to receive(:current).and_return(create(:license))
      allow(Settings.gitlab).to receive(:seat_link_enabled).and_return(seat_link_enabled)
    end

    context 'with seat link enabled' do
      let(:seat_link_enabled) { true }

      it 'redirects with a successful message' do
        post :sync_seat_link

        expect(response).to redirect_to(admin_license_path)
        expect(flash[:notice]).to eq('Your license was successfully synced.')
      end
    end

    context 'with seat link disabled' do
      let(:seat_link_enabled) { false }

      it 'redirects with an error message' do
        post :sync_seat_link

        expect(response).to redirect_to(admin_license_path)
        expect(flash[:error]).to match('There was an error when trying to sync your license.')
      end
    end
  end
end
