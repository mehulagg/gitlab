# frozen_string_literal: true

require 'securerandom'

module QA
  RSpec.describe 'Verify', :runner, :transient do
    describe 'Merge trains transient bugs' do
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
          project.name = 'merge-trains-transient-bugs'
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
        project.remove_via_api!
        group.remove_via_api!
      end

      it 'confirms that a merge train consistently completes and updates the UI', testcase: 'https://gitlab.com/gitlab-org/quality/testcases/-/issues/1608' do
        Runtime::Env.transient_trials.times do |i|
          QA::Runtime::Logger.info("Transient bug test action - Trial #{i}")

          random_string_for_this_trial = SecureRandom.hex(8)
          branch_name = "merge-train-#{random_string_for_this_trial}"
          title = "merge train transient bug test #{random_string_for_this_trial}"

          # Create a branch that will be merged into the default branch
          Resource::Repository::ProjectPush.fabricate! do |project_push|
            project_push.project = project
            project_push.new_branch = true
            project_push.branch_name = branch_name
            project_push.file_name = "file-#{random_string_for_this_trial}.txt"
            project_push.file_content = "merge me"
          end

          # Create a merge request to merge the branch we just created
          Resource::MergeRequest.fabricate_via_api! do |merge_request|
            merge_request.project = project
            merge_request.source_branch = branch_name
            merge_request.no_preparation = true
            merge_request.title = title
          end.visit!

          Page::MergeRequest::Show.perform do |show|
            pipeline_passed = show.retry_until(max_attempts: 5, sleep_interval: 5) do
              show.has_pipeline_status?(/Merged result pipeline #\d+ passed/)
            end

            expect(pipeline_passed).to be_truthy, "Expected the merged result pipeline to pass."

            show.merge_via_merge_train

            # This is also tested in pipelines_for_merged_results_and_merge_trains_spec.rb as a regular e2e test.
            # That test reloads the page at this point to avoid the problem of the merge status failing to update
            # That's the transient UX issue this test is checking for, so if the MR is merged but the UI still shows the
            # status as unmerged, the test will fail.

            merge_request = project.merge_request_with_title(title)

            expect(merge_request).not_to be_nil, "There was a problem fetching the merge request"

            # We use the API to wait until the MR has been merged so that we know the UI should be ready to update
            show.wait_until(reload: false) do
              mr = Resource::MergeRequest.fabricate_via_api! do |mr|
                mr.project = project
                mr.id = merge_request[:iid]
              end

              mr.state == 'merged'
            end

            expect(show).to be_merged, "Expected content 'The changes were merged' but it did not appear."
            expect(show).to have_pipeline_status(/Merge train pipeline #\d+ passed/)
          end
        end
      end
    end
  end
end
