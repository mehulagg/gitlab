# frozen_string_literal: true

module QA
  RSpec.describe 'Create' do
    describe 'Setup an MR with codeowners file' do
      let(:project) do
        Resource::Project.fabricate_via_api!
      end

      let(:target) do
        Resource::Repository::ProjectPush.fabricate! do |target|
          target.project = project
          target.branch_name = 'master'
          target.new_branch = true
          target.remote_branch = 'master'
          target.file_name = '.gitlab/CODEOWNERS'
          target.file_content = '* @root'
        end
      end

      let(:source) do
        Resource::Repository::ProjectPush.fabricate! do |source|
          source.project = project
          source.branch_name = 'codeowners_test'
          source.remote_branch = 'codeowners_test'
          source.new_branch = true
          source.file_name = 'test1.txt'
          source.file_content = '1'
        end

        Resource::Repository::ProjectPush.fabricate! do |source|
          source.project = project
          source.branch_name = 'codeowners_test'
          source.remote_branch = 'codeowners_test'
          source.new_branch = false
          source.file_name = 'test2.txt'
          source.file_content = '2'
        end
      end

      before do
        Runtime::Feature.enable('gitaly_go_user_merge_branch')
        Flow::Login.sign_in
      end

      after do
        Runtime::Feature.disable('gitaly_go_user_merge_branch')
      end

      it 'creates a merge request with codeowners file and squashing commits enabled', testcase: 'https://gitlab.com/gitlab-org/quality/testcases/-/issues/1090' do
        target.visit!

        Resource::ProtectedBranch.unprotect_via_api! do |branch|
          branch.new_branch = false
          branch.branch_name = 'master'
          branch.allowed_to_push = { roles: Resource::ProtectedBranch::Roles::NO_ONE }
          branch.allowed_to_merge = { roles: Resource::ProtectedBranch::Roles::MAINTAINERS }
          branch.protected = true
          branch.require_code_owner_approval = true
        end

        merge_request = Resource::MergeRequest.fabricate_via_api! do |mr|
          mr.no_preparation = true
          mr.project = project
          mr.source_branch = source.branch_name
          mr.target_branch = target.branch_name
          mr.title = 'merging two commits'
        end

        merge_request.visit!

        Page::MergeRequest::Show.perform do |mr|
          mr.mark_to_squash
          mr.merge!
        end

        expect(page).to have_content('The changes were merged')
      end
    end
  end
end
