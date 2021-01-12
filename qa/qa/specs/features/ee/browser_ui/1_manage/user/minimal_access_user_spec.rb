# frozen_string_literal: true

module QA
  RSpec.describe 'Manage' do
    describe 'User' do
      let(:group) do
        Resource::Group.fabricate_via_api! do |group|
          group.path = 'group-for-minimal-access'
        end
      end

      let(:project) do
        Resource::Project.fabricate_via_api! do |project|
          project.group = group
          project.name = "project-for-minimal-access"
          project.initialize_with_readme = true
        end
      end

      let(:user_with_minimal_access) { Resource::User.fabricate_via_api! }

      before do
        group.sandbox.add_member(user_with_minimal_access,  Resource::Members::AccessLevel::MINIMAL_ACCESS)
        project
      end

      context 'UI' do
        it 'limits access', testcase: 'https://gitlab.com/gitlab-org/quality/testcases/-/issues/1071' do
          Flow::Login.sign_in(as: user_with_minimal_access)
          project.visit!

          Page::Project::Show.perform do |project|
            project.click_file('README.md')
          end

          Page::File::Show.perform(&:click_edit)

          expect(page).to have_text("You're not allowed to edit files in this project directly.")
        end
      end
    end
  end
end
