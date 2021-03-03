# frozen_string_literal: true

module QA
  RSpec.describe 'Create', :runner do
    describe 'Merge requests' do
      let(:project) do
        Resource::Project.fabricate_via_api! do |project|
          project.name = 'merge-when-pipeline-succeeds'
          project.initialize_with_readme = true
        end
      end

      let!(:runner) do
        Resource::Runner.fabricate! do |runner|
          runner.project = project
          runner.name = "runner-for-#{project.name}"
          runner.tags = ["runner-for-#{project.name}"]
        end
      end

      before do
        Resource::Repository::Commit.fabricate_via_api! do |commit|
          commit.project = project
          commit.commit_message = 'Add .gitlab-ci.yml'
          commit.add_files(
            [
              {
                file_path: '.gitlab-ci.yml',
                content: <<~EOF
                  test:
                    tags: ["runner-for-#{project.name}"]
                    script: sleep 5
                    only:
                      - merge_requests
                EOF
              }
            ]
          )
        end

        Flow::Login.sign_in
      end

      after do
        runner&.remove_via_api!
        project&.remove_via_api!
      end

      it 'merges when pipeline succeeds', :smoke, testcase: 'https://gitlab.com/gitlab-org/quality/testcases/-/issues/1684' do
        branch_name = "merge-request-test-#{SecureRandom.hex(8)}"

        # Create a branch that will be merged into the default branch
        Resource::Repository::ProjectPush.fabricate! do |project_push|
          project_push.project = project
          project_push.new_branch = true
          project_push.branch_name = branch_name
          project_push.file_name = "file-#{SecureRandom.hex(8)}.txt"
        end

        # Create a merge request to merge the branch we just created
        merge_request = Resource::MergeRequest.fabricate_via_api! do |merge_request|
          merge_request.project = project
          merge_request.source_branch = branch_name
          merge_request.no_preparation = true
        end

        merge_request.visit!

        Page::MergeRequest::Show.perform do |mr|
          mr.merge_when_pipeline_succeeds!

          expect(mr.merge_request_status).to match(/to be merged automatically when the pipeline succeeds/)

          Support::Waiter.wait_until(sleep_interval: 5) do
            merge_request = merge_request.reload!
            merge_request.state == 'merged'
          end

          expect(mr.merged?).to be_truthy, "Expected content 'The changes were merged' but it did not appear."
        end
      end
    end
  end
end
