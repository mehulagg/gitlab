# frozen_string_literal: true

module QA
  RSpec.describe 'Manage', :github, :requires_admin do
    describe 'Project import' do
      let!(:user) do
        Resource::User.fabricate_via_api! do |resource|
          resource.api_client = Runtime::API::Client.as_admin
        end
      end

      let(:group) { Resource::Group.fabricate_via_api! }

      let(:imported_project) do
        Resource::ProjectImportedFromGithub.fabricate_via_browser_ui! do |project|
          project.name = 'imported-project'
          project.group = group
          project.github_personal_access_token = Runtime::Env.github_access_token
          project.github_repository_path = 'gitlab-qa/test-project'
        end
      end

      before do
        group.add_member(user, Resource::Members::AccessLevel::MAINTAINER)
      end

      after do
        user.remove_via_api!
        Page::Main::Menu.perform(&:sign_out_if_signed_in)
      end

      it 'imports a GitHub repo', testcase: 'https://gitlab.com/gitlab-org/quality/testcases/-/issues/385' do
        Flow::Login.sign_in(as: user)

        imported_project # import the project

        Page::Main::Menu.perform(&:go_to_projects)
        Page::Dashboard::Projects.perform do |dashboard|
          dashboard.go_to_project(imported_project.name)
        end

        Page::Project::Show.perform(&:wait_for_import)

        verify_repository_import
        verify_issues_import
        verify_merge_requests_import
        verify_labels_import
        verify_milestones_import
        verify_wiki_import
      end

      def verify_repository_import
        expect(page).to have_content('This test project is used for automated GitHub import by GitLab QA.')
        expect(page).to have_content(imported_project.name)
      end

      def verify_issues_import
        QA::Support::Retrier.retry_on_exception do
          Page::Project::Menu.perform(&:click_issues)
          expect(page).to have_content('This is a sample issue')

          click_link 'This is a sample issue'

          expect(page).to have_content('We should populate this project with issues, pull requests and wiki pages.')

          # Comments
          comment_text = 'This is a comment from @rymai.'

          Page::Project::Issue::Show.perform do |issue_page|
            expect(issue_page).to have_comment(comment_text)
            expect(issue_page).to have_label('enhancement')
            expect(issue_page).to have_label('help wanted')
            expect(issue_page).to have_label('good first issue')
          end
        end
      end

      def verify_merge_requests_import
        Page::Project::Menu.perform(&:click_merge_requests)
        expect(page).to have_content('Improve README.md')

        click_link 'Improve README.md'

        expect(page).to have_content('This improves the README file a bit.')

        # Review comment are not supported yet
        expect(page).not_to have_content('Really nice change.')

        # Comments
        expect(page).to have_content('Nice work! This is a comment from @rymai.')

        # Diff comments
        expect(page).to have_content('[Review comment] I like that!')
        expect(page).to have_content('[Review comment] Nice blank line.')
        expect(page).to have_content('[Single diff comment] Much better without this line!')

        Page::MergeRequest::Show.perform do |merge_request|
          expect(merge_request).to have_label('bug')
          expect(merge_request).to have_label('enhancement')
        end
      end

      def verify_labels_import
        # TODO: Waiting on https://gitlab.com/gitlab-org/gitlab-foss/merge_requests/19228
        # to build upon it.
      end

      def verify_milestones_import
        # TODO: Waiting on https://gitlab.com/gitlab-org/gitlab-foss/merge_requests/18727
        # to build upon it.
      end

      def verify_wiki_import
        Page::Project::Menu.perform(&:click_wiki)

        expect(page).to have_content('Welcome to the test-project wiki!')
      end
    end
  end
end
