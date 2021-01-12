# frozen_string_literal: true

module QA
  RSpec.describe 'Manage' do
    include Support::Api

    describe 'User with minimal access to group' do
      before(:all) do
        @user_with_minimal_access = Resource::User.fabricate_via_api!

        @user_api_client = Runtime::API::Client.new(:gitlab, user: @user_with_minimal_access)

        @group = Resource::Group.fabricate_via_api!

        @group.sandbox.add_member(@user_with_minimal_access, Resource::Members::AccessLevel::MINIMAL_ACCESS)

        @project = Resource::Project.fabricate_via_api! do |project|
          project.group = @group
          project.name = "project-for-minimal-access"
          project.initialize_with_readme = true
        end
      end

      it 'is not allowed to edit files via the UI', testcase: 'https://gitlab.com/gitlab-org/quality/testcases/-/issues/1071' do
        Flow::Login.sign_in(as: @user_with_minimal_access)
        @project.visit!

        Page::Project::Show.perform do |project|
          project.click_file('README.md')
        end

        Page::File::Show.perform(&:click_edit)

        expect(page).to have_text("You're not allowed to edit files in this project directly.")
      end

      it 'is not allowed to push code via the CLI' do
        expect do
          Resource::Repository::Push.fabricate! do |push|
            push.repository_http_uri = @project.repository_http_location.uri
            push.file_name = 'test.txt'
            push.file_content = "# This is a test project named #{project.name}"
            push.commit_message = 'Add test.txt'
            push.branch_name = 'new_branch'
            push.user = @user_with_minimal_access
          end.to raise_error(QA::Support::Run::CommandError, /You are not allowed to push code to this project/)
        end
      end

      it 'is not allowed to create a file via the API' do
        create_file_request = Runtime::API::Request.new(@user_api_client, "/projects/#{@project.id}/repository/files/text.txt")
        response = parse_body(post(create_file_request.url, branch: 'new_branch', content: 'Hello world', commit_message: 'Add text.txt'))

        expect(response[:message]).to eq('403 Forbidden')
      end

      after(:all) do
        @user_with_minimal_access.remove_via_api!
        @project.remove_via_api!
        @group.remove_via_api!
      end
    end
  end
end
