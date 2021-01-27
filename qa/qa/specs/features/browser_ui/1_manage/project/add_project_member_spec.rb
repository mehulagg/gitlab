# frozen_string_literal: true

module QA
  RSpec.describe 'Manage' do
    describe 'Add project member', :requires_admin do
      it 'user adds project member', testcase: 'https://gitlab.com/gitlab-org/quality/testcases/-/issues/482' do
        Flow::Login.sign_in

        user = Resource::User.fabricate_or_use(Runtime::Env.gitlab_qa_username_1, Runtime::Env.gitlab_qa_password_1)

        project = Resource::Project.fabricate_via_api! do |project|
          project.name = 'add-member-project'
        end

        Runtime::Feature.enable(:invite_members_group_modal)

        project.visit!

        Page::Project::Menu.perform(&:click_members)
        Page::Project::Members.perform do |members|
          members.add_member(user.username)

          expect(members).to have_content(/@#{user.username}( Is using seat)?(\n| )?Given access/)
        end
      end
    end
  end
end
