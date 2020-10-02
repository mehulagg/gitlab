# frozen_string_literal: true

module QA
  RSpec.describe 'Plan' do
    describe 'Assignees' do
      let(:user1) { Resource::User.fabricate_or_use(Runtime::Env.gitlab_qa_username_1, Runtime::Env.gitlab_qa_password_1) }
      let(:user2) { Resource::User.fabricate_or_use(Runtime::Env.gitlab_qa_username_2, Runtime::Env.gitlab_qa_password_2) }
      let(:project) do
        Resource::Project.fabricate_via_api! do |project|
          project.name = 'project-to-test-assignees'
        end
      end

      before do
        Flow::Login.sign_in

        project.add_member(user1)
        project.add_member(user2)
      end

      it 'update without refresh', testcase: 'https://gitlab.com/gitlab-org/quality/testcases/-/issues/1048' do
        issue = Resource::Issue.fabricate_via_api! do |issue|
          issue.project = project
          issue.assignee_ids = [user1.id]
        end

        issue.visit!

        Page::Project::Issue::Show.perform do |show|
          expect(show).to have_assignee(user1.name)

          issue.set_issue_assignees(assignee_ids: [user2.id])

          expect(show).to have_assignee(user2.name)
          expect(show).to have_no_assignee_named(user1.name)

          issue.set_issue_assignees(assignee_ids: [])

          expect(show).to have_no_assignee_named(user1.name)
          expect(show).to have_no_assignee_named(user2.name)
        end
      end
    end
  end
end
