# frozen_string_literal: true

RSpec.shared_examples 'import controller with status' do
  include ImportSpecHelper

  let_it_be(:group) { create(:group) }

  before do
    group.add_owner(user)
  end

  describe "GET realtime_changes" do
    it 'returns a list of imported projects' do
      created_project = create(:project, import_type: provider_name, namespace: user.namespace, import_source: import_source)

      get :realtime_changes

      expect(json_response.count).to eq(1)
      expect(json_response.first['id']).to eq(created_project.id)
      expect(json_response.first['import_status']).to eq('none')
    end
  end

  describe "GET status" do
    it "returns variables for json request" do
      project = create(:project, import_type: provider_name, creator_id: user.id)
      stub_client(client_repos_field => [repo])

      get :status, format: :json

      expect(response).to have_gitlab_http_status(:ok)
      expect(json_response.dig("imported_projects", 0, "id")).to eq(project.id)
      expect(json_response.dig("provider_repos", 0, "id")).to eq(repo_id)
      expect(json_response.dig("namespaces", 0, "id")).to eq(group.id)
    end

    it "does not show already added project" do
      project = create(:project, import_type: provider_name, namespace: user.namespace, import_status: :finished, import_source: import_source)
      stub_client(client_repos_field => [repo])

      get :status, format: :json

      expect(json_response.dig("imported_projects", 0, "id")).to eq(project.id)
      expect(json_response.dig("provider_repos")).to eq([])
    end
  end
end
