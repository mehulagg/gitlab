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

      let!(:group) do
        group = QA::Resource::Group.fabricate_via_api!
        group.add_member(user)
        group
      end

      let(:project) do
        Resource::Project.fabricate_via_api! do |project|
          project.name = 'project-for-tags'
          project.initialize_with_readme = true
          project.api_client = user_api_client
          project.group = group
        end
      end

      it 'can be followed and their activity seen', testcase: 'https://gitlab.com/gitlab-org/quality/testcases/-/issues/1663' do
        navigate_to_user_profile(user)

        Page::User::Show.perform(&:click_follow_user_link)

        expect(page).to have_text("No activities found")

        project

        Flow::Login.sign_in_unless_signed_in

        Page::Main::Menu.perform(&:click_user_profile_link)

        Page::User::Show.perform do |show|
          show.click_following_link
          show.click_user_link(user.username)
          expect(show).to have_activity('created project')
        end
      end

      def navigate_to_user_profile(user)
        Flow::Login.sign_in_unless_signed_in
        page.visit Runtime::Scenario.gitlab_address + "/#{user.username}"
      end

      after do
        project.api_client = admin_api_client
        project.remove_via_api!
        user.remove_via_api!
      end
    end
  end
end
