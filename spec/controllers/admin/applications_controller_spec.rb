require 'spec_helper'

describe Admin::ApplicationsController do
  let(:admin) { create(:admin) }
  let(:application) { create(:oauth_application, owner_id: nil, owner_type: nil) }

  before do
    sign_in(admin)
  end

  describe 'GET #new' do
    it 'renders the application form' do
      get :new

      expect(response).to render_template :new
      expect(assigns[:scopes]).to be_kind_of(Doorkeeper::OAuth::Scopes)
    end
  end

  describe 'GET #edit' do
    it 'renders the application form' do
      get :edit, id: application.id

      expect(response).to render_template :edit
      expect(assigns[:scopes]).to be_kind_of(Doorkeeper::OAuth::Scopes)
    end
  end

  describe 'POST #create' do
    it 'creates the application' do
      expect do
        post :create, doorkeeper_application: attributes_for(:application)
      end.to change { Doorkeeper::Application.count }.by(1)

      application = Doorkeeper::Application.last

      expect(response).to redirect_to(admin_application_path(application))
    end

    it 'renders the application form on errors' do
      expect do
        post :create, doorkeeper_application: attributes_for(:application).merge(redirect_uri: nil)
      end.not_to change { Doorkeeper::Application.count }

      expect(response).to render_template :new
      expect(assigns[:scopes]).to be_kind_of(Doorkeeper::OAuth::Scopes)
    end
  end

  describe 'PATCH #update' do
    it 'updates the application' do
      patch :update, id: application.id, doorkeeper_application: { redirect_uri: 'http://example.com/' }

      expect(response).to redirect_to(admin_application_path(application))
      expect(application.reload.redirect_uri).to eq 'http://example.com/'
    end

    it 'renders the application form on errors' do
      patch :update, id: application.id, doorkeeper_application: { redirect_uri: nil }

      expect(response).to render_template :edit
      expect(assigns[:scopes]).to be_kind_of(Doorkeeper::OAuth::Scopes)
    end
  end
end
