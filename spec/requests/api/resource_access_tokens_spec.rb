require "spec_helper"

RSpec.describe API::ResourceAccessTokens do
  describe "GET /:id/access_tokens" do
    context "when the resource is a project" do 
      let_it_be(:admin) { create(:admin) }
      let_it_be(:resource) { create(:project) }
 
      before do 
        resource.add_maintainer(admin)
        
      end
      
      it "gets a list of resource access tokens for the specified project" do
        access_token = ResourceAccessTokens::CreateService.new(admin, resource, {} ).execute
        get api("/projects/#{resource.id}/access_tokens", admin)

        expect(response).to have_gitlab_http_status(:ok)
       # binding.pry
        my_json_response = json_response.first

        expect(my_json_response["id"]).to eq(access_token.id)
        expect(my_json_response["name"]).to eq(access_token.name)
        expect(my_json_response["scopes"]).to eq(access_token.scopes)
        expect(my_json_response["created_at"]).to be_present
        expect(my_json_response["expires_at"]).to eq(access_token.expires_at)
        expect(my_json_response["active"]).to be_truthy
        expect(my_json_response["revoked"]).to be_falsey
      end
    end
  end
end
