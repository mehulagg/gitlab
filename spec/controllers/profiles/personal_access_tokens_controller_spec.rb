require 'spec_helper'

describe Profiles::PersonalAccessTokensController do
  let(:user) { create(:user) }
  let(:token_attributes) { attributes_for(:personal_access_token) }

  before do
    sign_in(user)
  end

  describe '#create' do
    def created_token
      PersonalAccessToken.order(:created_at).last
    end

    it "allows creation of a token with scopes" do
      name = 'My PAT'
      scopes = %w[api read_user]

      post :create, personal_access_token: token_attributes.merge(scopes: scopes, name: name)

      expect(created_token).not_to be_nil
      expect(created_token.name).to eq(name)
      expect(created_token.scopes).to eq(scopes)
      expect(PersonalAccessToken.active).to include(created_token)
    end

    it "allows creation of a token with an expiry date" do
      expires_at = 5.days.from_now.to_date

      post :create, personal_access_token: token_attributes.merge(expires_at: expires_at)

      expect(created_token).not_to be_nil
      expect(created_token.expires_at).to eq(expires_at)
    end

    it "tokens are not restricted by project by default" do
      post :create, personal_access_token: token_attributes

      expect(created_token).not_to be_restricted_by_resource
    end

    it "allows creation of tokens restricted by project" do
      allowed_project = create(:project)
      restricted_project = create(:project)

      post :create, personal_access_token: token_attributes.merge(project_ids: [allowed_project.id])

      expect(created_token).to be_restricted_by_resource
      expect(created_token.allows_resource?(allowed_project)).to be_truthy
      expect(created_token.allows_resource?(restricted_project)).to be_falsey
    end
  end

  describe '#index' do
    let!(:active_personal_access_token) { create(:personal_access_token, user: user) }
    let!(:inactive_personal_access_token) { create(:personal_access_token, :revoked, user: user) }
    let!(:impersonation_personal_access_token) { create(:personal_access_token, :impersonation, user: user) }

    before do
      get :index
    end

    it "retrieves active personal access tokens" do
      expect(assigns(:active_personal_access_tokens)).to include(active_personal_access_token)
    end

    it "retrieves inactive personal access tokens" do
      expect(assigns(:inactive_personal_access_tokens)).to include(inactive_personal_access_token)
    end

    it "does not retrieve impersonation personal access tokens" do
      expect(assigns(:active_personal_access_tokens)).not_to include(impersonation_personal_access_token)
      expect(assigns(:inactive_personal_access_tokens)).not_to include(impersonation_personal_access_token)
    end
  end
end
