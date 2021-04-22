# frozen_string_literal: true

module QA
  RSpec.describe 'Manage' do
    describe 'User', :requires_admin do
      let(:admin_api_client) { Runtime::API::Client.as_admin }

      let!(:user) do
        Resource::User.fabricate_via_api! do |user|
          user.api_client = admin_api_client
        end
      end

      let!(:user_api_client) do
        Runtime::API::Client.new(:gitlab, user: user)
      end

      let(:project) do
        Resource::Project.fabricate_via_api! do |project|
          project.initialize_with_readme = true
          project.api_client = user_api_client
        end
      end

      it 'can be followed and their activity seen', testcase: 'https://gitlab.com/gitlab-org/quality/testcases/-/issues/1663' do
        Flow::Login.sign_in
        project.visit!

        Page::Project::Show.perform do |project|
          project.click_file('README.md')
        end

        Page::File::Show.perform(&:click_edit)

        expect(page).to have_text("You're not allowed to edit files in this project directly.")
      end

      after do
        user.remove_via_api!
        project.remove_via_api!
        group.remove_via_api!
      end
    end
  end
end
