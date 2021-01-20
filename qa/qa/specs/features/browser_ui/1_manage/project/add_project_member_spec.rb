# frozen_string_literal: true

module QA
  RSpec.describe 'Manage' do
    let(:project) do
      Resource::Project.fabricate_via_api! do |project|
        project.name = 'add-member-project'
      end
    end

    before do
      Runtime::Feature.enable('invite_members_group_modal', group: project.group)
    end

    describe 'Invite Members' do
      it 'has a link to the Invite Members modal', testcase: 'https://gitlab.com/gitlab-org/quality/testcases/-/issues/482' do
        Flow::Login.sign_in

        project.visit!

        Page::Project::Menu.perform(&:click_members)

        Page::Project::Members.perform do |members|
          expect(members).to have_link('Invite members')

          members.open_invite_members_modal

          expect(members).to have_content("You're inviting members to the #{project.name.upcase} project")
        end
      end
    end

    describe 'Display added member' do
      it 'displays project member' do
        Flow::Login.sign_in

        user = Resource::User.fabricate_or_use(Runtime::Env.gitlab_qa_username_1, Runtime::Env.gitlab_qa_password_1)

        project.visit!

        Page::Project::Menu.perform(&:click_members)

        Page::Project::Members.perform do |members|
          members.add_member(user.username)

          expect(members).to have_content(/@#{user.username}( Is using seat)?(\n| )?Given access/)
        end
      end
    end

    describe 'Invite Group' do
      it 'has a link to the Invite Group modal', testcase: 'https://gitlab.com/gitlab-org/quality/testcases/-/issues/482' do
        Flow::Login.sign_in

        project.visit!

        Page::Project::Menu.perform(&:click_members)

        Page::Project::Members.perform do |members|
          expect(members).to have_link('Invite a group')

          members.open_invite_group_modal

          expect(members).to have_content("You're inviting a group to the #{project.name.upcase} project")
        end
      end
    end
  end
end
