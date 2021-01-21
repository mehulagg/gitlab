# frozen_string_literal: true

require "spec_helper"

RSpec.describe API::ResourceAccessTokens do
  before do
    resource.add_maintainer(admin)
  end

  let_it_be(:admin) { create(:admin) }
  let_it_be(:resource) { create(:project) }

  describe "GET /:id/access_tokens" do
    context "when the resource is a project" do
      before do
        resource.add_maintainer(admin)
      end

      it "gets a list of resource access tokens for the specified project" do
        ResourceAccessTokens::CreateService.new(admin, resource, {} ).execute
        get api("/projects/#{resource.id}/access_tokens", admin)

        expect(response).to have_gitlab_http_status(:ok)
      end
    end
  end

  describe "DELETE /:id/access_tokens/:token_id" do
    context "when the resource is a project" do
      before do
        resource.add_maintainer(admin)
      end

      it "deletes the project access token from the project" do
        token = ResourceAccessTokens::CreateService.new(admin, resource, {} ).execute

        delete api("/projects/#{resource.id}/access_tokens/#{token.payload[:access_token].id}", admin)

        expect(response).to have_gitlab_http_status(:no_content)
      end
    end
  end

  describe "POST /:id/access_tokens" do
    context 'when resource is a project'
    let_it_be(:params) { { name: 'Random bot', scopes: ["api"] } }

    before do
      resource.add_maintainer(admin)
    end

    it 'creates a project access token with the params' do
      post api("/projects/#{resource.id}/access_tokens", admin), params: params

      expect(response).to have_gitlab_http_status(:created)
    end
  end
end
