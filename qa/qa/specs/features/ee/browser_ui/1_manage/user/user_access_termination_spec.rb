# frozen_string_literal: true

module QA
  RSpec.describe 'Manage' do
    describe 'User', :requires_admin do
      let(:user) { Resource::User.fabricate_via_api! }

      let(:group) do
        group = Resource::Group.fabricate_via_api!
        group.sandbox.add_member(user)
        group
      end

      let(:project) do
        Resource::Project.fabricate_via_api! do |project|
          project.group = group
          project.name = "project-for-user-access-termination"
          project.initialize_with_readme = true
        end
      end

      it 'is not allowed to access the project after membership termination' do
        Flow::Login.while_signed_in_as_admin do
          group.sandbox.visit!

          Page::Group::Menu.perform(&:click_group_members_item)
          Page::Group::Members.perform do |members_page|
            members_page.remove_member(user.username)
          end
        end

        Flow::Login.sign_in(as: user)
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
