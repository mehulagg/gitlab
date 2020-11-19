# frozen_string_literal: true

module QA
  RSpec.describe 'Create' do
    describe 'Setup an MR with codeowners file' do
      let(:project) do
        Resource::Project.fabricate_via_api!
      end

      let(:target) do
        Resource::Repository::ProjectPush.fabricate! do |target|
          resource.project = project
          resource.branch_name = 'master'
          resource.new_branch = true
          resource.remote_branch = 'master'
          resource.file_name = '.gitlab/CODEOWNERS'
          resource.file_content = '* @root'
        end
      end

      let(:source) do
        Resource::Repository::ProjectPush.fabricate! do |source|
          resource.project = project
          resource.branch_name = 'codeowners_test'
          resource.remote_branch = 'codeowners_test'
          resource.new_branch = true
          resource.file_name = 'test1.txt'
          resource.file_content = '1'
        end

        Resource::Repository::ProjectPush.fabricate! do |source|
          resource.project = project
          resource.branch_name = 'codeowners_test'
          resource.remote_branch = 'codeowners_test'
          resource.new_branch = false
          resource.file_name = 'test2.txt'
          resource.file_content = '2'
        end
      end

      before do
        Runtime::Feature.enable('gitaly_go_user_merge_branch')
        Flow::Login.sign_in
      end

      after do
        Runtime::Feature.disable('gitaly_go_user_merge_branch')
      end

      it 'creates a merge request with codeowners file and squashing commits enabled' do
        target.visit!

        Resource::ProtectedBRanch.fabricate_via_api! do |branch|
          branch.new_branch = false
          branch.branch_name = 'master'
          branch.allowed_to_push = { roles: Resource::ProtectedBranch::Roles::NO_ONE }
          branch.allowed_to_merge = { roles: Resource::ProtectedBranch::Roles::MAINTAINERS }
          branch.protected = true
          branch.require_code_owner_approval = true
        end

        Resource::MergeRequest.fabricate_via_api! do |mr|
          mr.no_preparation = true
          mr.source_branch = source.branch_name
          mr.target_branch = target.branch_name
          mr.title = 'merging two commits'
        end
      end
    end
  end
end
