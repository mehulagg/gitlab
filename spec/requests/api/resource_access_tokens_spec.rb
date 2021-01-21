# frozen_string_literal: true

require "spec_helper"

RSpec.describe API::ResourceAccessTokens do
  context "when the resource is a project" do
    let_it_be(:project) { create(:project) }
    let_it_be(:admin) { create(:admin) }
    let_it_be(:user) { create(:user) }

    describe "GET /:id/access_tokens" do
      context "when the user has valid permissions" do
        let_it_be(:project_bot) { create(:user, :project_bot) }
        let_it_be(:access_tokens) { create_list(:personal_access_token, 3, user: project_bot) }

        before do
          project.add_maintainer(admin)
          project.add_maintainer(project_bot)
        end

        it "gets a list of access tokens for the specified project" do
          get api("/projects/#{project.id}/access_tokens", admin)

          expect(response).to have_gitlab_http_status(:ok)

          token_ids = json_response.map { |token| token['id'] }
          expect(token_ids).to match_array(access_tokens.pluck(:id))
        end

        context "when tokens belong to a different project" do
          let_it_be(:other_project) { create(:project) }
          let_it_be(:bot) { create(:user, :project_bot) }
          let_it_be(:token) { create(:personal_access_token, user: bot) }

          before do
            other_project.add_maintainer(bot)
          end

          it "does not return tokens from a different project" do
            get api("/projects/#{project.id}/access_tokens", admin)
            token_ids = json_response.map { |token| token['id'] }
            expect(token_ids).to match_array(access_tokens.pluck(:id))

            expect(token_ids).not_to include(token.id)
          end
        end

        context "when the project has no access tokens" do
          let_it_be(:new_project) { create(:project) }
          it 'returns an empty array' do
            get api("/projects/#{new_project.id}/access_tokens", admin)

            expect(response).to have_gitlab_http_status(:ok)
            expect(json_response).to eq([])
          end
        end

        context "when the project does not exist" do
          it "returns 404" do
            get api("/projects/1337369/access_tokens", admin)

            expect(response).to have_gitlab_http_status(:not_found)
          end
        end
      end

      context "when the user does not have valid permissions" do
        let_it_be(:project_bot) { create(:user, :project_bot) }
        let_it_be(:access_tokens) { create_list(:personal_access_token, 3, user: project_bot) }

        before do
          project.add_developer(user)
          project.add_maintainer(project_bot)
        end

        it "returns 401 Unauthorized" do
          get api("/projects/#{project.id}/access_tokens", user)

          expect(response).to have_gitlab_http_status(:unauthorized)
        end
      end
    end

    describe "DELETE /:id/access_tokens/:token_id" do
      let_it_be(:project_bot) { create(:user, :project_bot) }
      let_it_be(:token) { create(:personal_access_token, user: project_bot) }

      before do
        project.add_maintainer(admin)
        project.add_maintainer(project_bot)
      end

      context "when the user has valid permissions" do
        it "deletes the project access token from the project" do
          delete api("/projects/#{project.id}/access_tokens/#{token.id}", admin)

          expect(response).to have_gitlab_http_status(:no_content)
        end
      end

      context "when the user does not have valid permissions" do
        before do
          project.add_developer(user)
        end

        it "does not delete the token, and returns 400" do
          delete api("/projects/#{project.id}/access_tokens/#{token.id}", user)

          expect(response).to have_gitlab_http_status(:bad_request)
          expect(response.body).to include("#{user.name} cannot delete #{token.user.name}")
        end
      end

      context "when attempting to delete a non-existent project access token" do
        it "does not delete the token, and returns 404" do
          delete api("/projects/#{project.id}/access_tokens/1337", admin)

          expect(response).to have_gitlab_http_status(:not_found)
        end
      end
    end

    describe "POST /:id/access_tokens" do
      context "when the user has valid permissions" do
        before do
          project.add_maintainer(admin)
        end

        context "with valid params" do
          context "with full params" do
            let_it_be(:full_params) { { name: 'test', scopes: ["api"], expires_at: Date.today + 1.month } }

            it 'creates a project access token with the params' do
              post api("/projects/#{project.id}/access_tokens", admin), params: full_params

              expect(response).to have_gitlab_http_status(:created)
              expect(json_response["name"]).to eq('test')
              expect(json_response["scopes"]).to eq(["api"])
              expect(json_response["expires_at"]).to eq((Date.today + 1.month).iso8601)
            end
          end

          context "when 'expires_at' is not set" do
            let_it_be(:params_missing_expires_at) { { name: 'test', scopes: ["api"] } }

            it 'creates a project access token with the params' do
              post api("/projects/#{project.id}/access_tokens", admin), params: params_missing_expires_at

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
              post api("/projects/#{project.id}/access_tokens", admin), params: params_missing_name

              expect(response).to have_gitlab_http_status(:bad_request)
              expect(response.body).to include("name is missing")
            end
          end

          context "when missing the 'scopes' param" do
            let_it_be(:params_missing_scope) { { name: 'test', expires_at: 5.days.from_now } }

            it 'does not creates a project access token with the params' do
              post api("/projects/#{project.id}/access_tokens", admin), params: params_missing_scope

              expect(response).to have_gitlab_http_status(:bad_request)
              expect(response.body).to include("scopes is missing")
            end
          end
        end
      end

      context "when the user does not have valid permissions" do
        let_it_be(:params) { { name: 'test', scopes: ["api"], expires_at: Date.today + 1.month } }

        before do
          project.add_developer(user)
        end

        it 'creates a project access token with the params' do
          post api("/projects/#{project.id}/access_tokens", user), params: params

          expect(response).to have_gitlab_http_status(:bad_request)
          expect(response.body).to include("User does not have permission to create project Access Token")
        end
      end
    end
  end
end
