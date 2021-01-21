# frozen_string_literal: true

require "spec_helper"

RSpec.describe API::ResourceAccessTokens do
  context 'when the resource is a project' do
    let_it_be(:admin) { create(:admin) }
    let_it_be(:user) { create(:user) }
    let_it_be(:resource) { create(:project) }

    describe "GET /:id/access_tokens" do
      before do
        resource.add_maintainer(admin)
        ResourceAccessTokens::CreateService.new(admin, resource, {} ).execute
      end

      context "when the user has valid permissions" do
        it "gets a list of resource access tokens for the specified project" do
          get api("/projects/#{resource.id}/access_tokens", admin)

          expect(response).to have_gitlab_http_status(:ok)
        end
      end

      context "when the user does not have valid permissions" do
        it "returns 401 Unauthorized" do
          get api("/projects/#{resource.id}/access_tokens", user)

          expect(response).to have_gitlab_http_status(:unauthorized)
        end
      end
    end

    describe "DELETE /:id/access_tokens/:token_id" do
      before do
        resource.add_maintainer(admin)
        @token = ResourceAccessTokens::CreateService.new(admin, resource, {} ).execute
      end

      context "when the user has valid permissions" do
        it "deletes the project access token from the project" do
          delete api("/projects/#{resource.id}/access_tokens/#{@token.payload[:access_token].id}", admin)

          expect(response).to have_gitlab_http_status(:no_content)
        end
      end

      context "when the user does not have valid permissions" do
        before do
          resource.add_developer(user)
        end

        it "does not delete the token, and returns 400" do
          delete api("/projects/#{resource.id}/access_tokens/#{@token.payload[:access_token].id}", user)

          expect(response).to have_gitlab_http_status(:bad_request)
          expect(response.body).to include("#{user.name} cannot delete #{@token.payload[:access_token].user.name}")
        end
      end

      context "when attempting to delete a non-existent project access token" do
        it "does not delete the token, and returns 404" do
          delete api("/projects/#{resource.id}/access_tokens/1337", admin)

          expect(response).to have_gitlab_http_status(:not_found)
        end
      end
    end

    describe "POST /:id/access_tokens" do
      context "when the user has valid permissions" do
        before do
          resource.add_maintainer(admin)
        end

        context "with valid params" do
          context "with full params" do
            let_it_be(:full_params) { { name: 'test', scopes: ["api"], expires_at: Date.today + 1.month } }

            it 'creates a project access token with the params' do
              post api("/projects/#{resource.id}/access_tokens", admin), params: full_params

              expect(response).to have_gitlab_http_status(:created)
              expect(json_response["name"]).to eq('test')
              expect(json_response["scopes"]).to eq(["api"])
              expect(json_response["expires_at"]).to eq((Date.today + 1.month).iso8601)
            end
          end

          context "when 'expires_at' is not set" do
            let_it_be(:params_missing_expires_at) { { name: 'test', scopes: ["api"] } }

            it 'creates a project access token with the params' do
              post api("/projects/#{resource.id}/access_tokens", admin), params: params_missing_expires_at

              expect(response).to have_gitlab_http_status(:created)
              expect(json_response["name"]).to eq('test')
              expect(json_response["scopes"]).to eq(["api"])
              expect(json_response["expires_at"]).to eq(nil)
            end
          end
        end

        context "with invalid params" do
          context "when missing the 'name' param" do
            let_it_be(:params_missing_name) { { scopes: ["api"], expires_at: 5.days.from_now } }

            it 'does not creates a project access token with the params' do
              post api("/projects/#{resource.id}/access_tokens", admin), params: params_missing_name

              expect(response).to have_gitlab_http_status(:bad_request)
              expect(response.body).to include("name is missing")
            end
          end

          context "when missing the 'scopes' param" do
            let_it_be(:params_missing_scope) { { name: 'test', expires_at: 5.days.from_now } }

            it 'does not creates a project access token with the params' do
              post api("/projects/#{resource.id}/access_tokens", admin), params: params_missing_scope

              expect(response).to have_gitlab_http_status(:bad_request)
              expect(response.body).to include("scopes is missing")
            end
          end
        end
      end
    end
  end
end
