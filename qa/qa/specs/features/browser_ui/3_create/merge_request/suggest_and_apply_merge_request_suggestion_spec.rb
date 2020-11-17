# frozen_string_literal: true

module QA
  RSpec.describe 'Create' do
    describe 'Suggest and apply a merge request suggestion' do

      let(:project) do
        Resource::Project.fabricate_via_api! do |project|
          project.name = 'Test-Project'
          project.initialize_with_readme = true
        end
      end

      let :dev_user do
        Resource::User.fabricate_via_api!('developer-user', 'dev_passwd')
      end

      let(:developer_api_client) { Runtime::API::Client.new(:gitlab, user: dev_user) }

      let(:add_member_to_project) do
        Resource::ProjectMember.fabricate_via_api! do |member|
          member.user = dev_user
          member.project = project
          member.access_level = member.level[:maintainer]
        end
      end

      let(:key) do
        Resource::SSHKey.fabricate_via_api! do |resource|
          resource.api_client = developer_api_client
          resource.title = "key for ssh tests #{Time.now.to_f}"
        end
      end

      let(:merge_request_title) { 'Merge Request by developer-user' }
      let(:merge_request_description) { 'Merge request for applying suggestion' }

      let(:merge_request) do
        Resource::MergeRequest.fabricate_via_api! do |merge_request|
          merge_request.api_client = developer_api_client
          merge_request.project = project
          merge_request.title = merge_request_title
          merge_request.description = merge_request_description
          merge_request.source_branch = 'dev-branch'
          merge_request.target_branch = 'master'
          merge_request.no_preparation = true
          merge_request.assignee = @root
        end
      end

      before do
        add_member_to_project

        developer_commits_file_to_new_branch_using_ssh
      end

      it 'suggests and applies a merge request suggestion' do
        merge_and_suggest_using_insert_suggestion_button

        apply_suggestion

        merge_request_and_ensure_success
      end

      def developer_commits_file_to_new_branch_using_ssh
        Resource::Repository::ProjectPush.fabricate! do |push|
          push.project = project
          push.ssh_key = key
          push.file_name = 'README.md'
          push.file_content = '# Test for readme'
          push.commit_message = 'Add README.md'
          push.new_branch = true
          push.branch_name = 'dev-branch'
        end
      end

      def merge_and_suggest_using_insert_suggestion_button
        Flow::Login.sign_in

        merge_request.visit!

        Page::MergeRequest::Show.perform do |merge_request|
          merge_request.click_diffs_tab
          merge_request.click_line_to_comment('# Test for readme')
          merge_request.comment_on_line
          merge_request.click_insert_suggestion_button
          merge_request.insert_suggestion(" change this")
          merge_request.start_review
          merge_request.submit_pending_reviews
        end
      end

      def apply_suggestion
        Flow::Login.sign_in(as: dev_user)

        merge_request.visit!

        Page::MergeRequest::Show.perform do |merge_request|
          merge_request.click_diffs_tab
          merge_request.click_apply_suggestion_button
          expect(merge_request).to have_success_badge
        end
      end

      def merge_request_and_ensure_success
        Flow::Login.sign_in

        merge_request.visit!

        Page::MergeRequest::Show.perform do |merge_request|
          merge_request.accept_merge_request
        end

        project.visit!

        Page::Project::Show.perform do |project|
          expect(project).to have_file('README.md')
          expect(project).to have_readme_content('Test for readme change this')
        end
      end
    end
  end
end
