# frozen_string_literal: true

require 'securerandom'

module QA
  RSpec.describe 'Verify', :runner do
    describe 'Pipelines for merged results and merge trains' do
      let(:group) { Resource::Group.fabricate_via_api! }

      let!(:runner) do
        Resource::Runner.fabricate_via_api! do |runner|
          runner.token = group.reload!.runners_token
          runner.name = group.name
          runner.tags = [group.name]
          runner.project = project
        end
      end

      let(:project) do
        Resource::Project.fabricate_via_api! do |project|
          project.name = 'pipelines-for-merged-results-and-merge-trains'
          project.group = group
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
                    tags: [#{group.name}]
                    script: echo 'OK'
                    only:
                    - merge_requests
                EOF
              }
            ]
          )
        end

        Flow::Login.sign_in
        project.visit!

        Page::Project::Menu.perform(&:go_to_general_settings)
        Page::Project::Settings::Main.perform do |main|
          main.expand_merge_requests_settings do |settings|
            settings.click_pipelines_for_merged_results_checkbox
            settings.click_merge_trains_checkbox
            settings.click_save_changes
          end
        end
      end

      after do
        runner.remove_via_api! if runner
      end

      it 'creates a pipeline with merged results', testcase: 'https://gitlab.com/gitlab-org/quality/testcases/-/issues/562' do
        branch_name = "merged-results-#{SecureRandom.hex(8)}"

        # Create a branch that will be merged into the default branch
        Resource::Repository::ProjectPush.fabricate! do |project_push|
          project_push.project = project
          project_push.new_branch = true
          project_push.branch_name = branch_name
          project_push.file_name = "file-#{SecureRandom.hex(8)}.txt"
        end

        # Create a merge request to merge the branch we just created
        Resource::MergeRequest.fabricate_via_api! do |merge_request|
          merge_request.project = project
          merge_request.source_branch = branch_name
          merge_request.no_preparation = true
        end.visit!

        Page::MergeRequest::Show.perform do |show|
          pipeline_passed = Support::Retrier.retry_until(max_attempts: 5, sleep_interval: 5) do
            show.has_pipeline_status?(/Merged result pipeline #\d+ passed/)
          end

          expect(pipeline_passed).to be_truthy, "Expected the merged result pipeline to pass."

          # The default option is to merge via merge train,
          # but that is covered by the 'merges via a merge train' test
          show.skip_merge_train_and_merge_immediately
        end

        merged = Page::MergeRequest::Show.perform(&:merged?)

        expect(merged).to be_truthy, "Expected content 'The changes were merged' but it did not appear."
      end

      it 'merges via a merge train', testcase: 'https://gitlab.com/gitlab-org/quality/testcases/-/issues/561' do
        branch_name = "merge-train-#{SecureRandom.hex(8)}"

        # Create a branch that will be merged into the default branch
        Resource::Repository::ProjectPush.fabricate! do |project_push|
          project_push.project = project
          project_push.new_branch = true
          project_push.branch_name = branch_name
          project_push.file_name = "file-#{SecureRandom.hex(8)}.txt"
          project_push.file_content = "merge me"
        end

        # Create a merge request to merge the branch we just created
        Resource::MergeRequest.fabricate_via_api! do |merge_request|
          merge_request.project = project
          merge_request.source_branch = branch_name
          merge_request.no_preparation = true
        end.visit!

        Page::MergeRequest::Show.perform do |show|
          pipeline_passed = show.retry_until(max_attempts: 5, sleep_interval: 5) do
            show.has_pipeline_status?(/Merged result pipeline #\d+ passed/)
          end

          expect(pipeline_passed).to be_truthy, "Expected the merged result pipeline to pass."

          show.merge_via_merge_train

          # It's faster to refresh the page than to wait for the UI to
          # automatically refresh, so we reload if the merge status
          # doesn't update quickly.
          merged = show.retry_until(max_attempts: 5, reload: true, sleep_interval: 5) do
            show.merged?
          end

          expect(merged).to be_truthy, "Expected content 'The changes were merged' but it did not appear."
          expect(show).to have_pipeline_status(/Merge train pipeline #\d+ passed/)
        end
      end
    end
  end
end
