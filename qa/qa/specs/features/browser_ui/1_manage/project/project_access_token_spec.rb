# frozen_string_literal: true

module QA
  RSpec.describe 'Manage' do
    describe 'Project access tokens' do
      it 'can be created via the UI' do
        project_access_token = QA::Resource::ProjectAccessToken.fabricate_via_browser_ui!.token
        expect(project_access_token).not_to be_nil
      end

      it 'can be used to access the project API', testcase: 'https://gitlab.com/gitlab-org/quality/testcases/-/issues/1705' do
        project_access_token = QA::Resource::ProjectAccessToken.fabricate_via_api!
        user_api_client = Runtime::API::Client.new(:gitlab, personal_access_token: project_access_token.token)

        expect do
          Resource::File.fabricate_via_api! do |file|
            file.api_client = user_api_client
            file.project = project_access_token.project
            file.branch = 'new_branch'
            file.commit_message = 'Add new file'
            file.name = 'test.txt'
            file.content = 'New file'
          end
        end.not_to raise_error
      end
    end
  end
end
