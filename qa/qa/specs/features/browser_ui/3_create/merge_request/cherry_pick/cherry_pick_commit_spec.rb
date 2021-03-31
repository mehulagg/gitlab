# frozen_string_literal: true

module QA
  RSpec.describe 'Create' do
    describe 'Cherry picking a commit' do
      let(:project) do
        Resource::Project.fabricate_via_api! do |project|
          project.name = 'project'
          project.initialize_with_readme = true
        end
      end

      let(:commit) do
        Resource::Repository::Commit.fabricate_via_api! do |commit|
          commit.project = project
          commit.branch = "development"
          commit.start_branch = project.default_branch
          commit.commit_message = 'Add new file'
          commit.add_files([
            { file_path: "secret_file.md", content: 'pssst!' }
          ])
        end
      end

      before do
        Flow::Login.sign_in
        commit.visit!
      end

      it 'user views raw email patch', testcase: 'https://gitlab.com/gitlab-org/quality/testcases/-/issues/442' do
        Page::Project::Commit::Show.perform(&:cherry_pick_commit)
      end
    end
  end
end
