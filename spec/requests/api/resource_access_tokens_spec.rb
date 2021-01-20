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
      end
    end
  end
end
