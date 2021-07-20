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

      let!(:ci_file) do
        Resource::Repository::Commit.fabricate_via_api! do |commit|
          commit.project = project
          commit.commit_message = 'Add .gitlab-ci.yml'
          commit.add_files(
            [
              {
                file_path: '.gitlab-ci.yml',
                content: <<~YAML
                  test:
                    tags: [#{group.name}]
                    script: echo 'OK'
                    only:
                    - merge_requests
                YAML
              }
            ]
          )
        end
      end

      before do
        Flow::Login.sign_in
        project.visit!
        Flow::MergeRequest.enable_merge_trains
      end

      after do
        runner.remove_via_api! if runner
        project.remove_via_api!
        group.remove_via_api!
      end

      it 'confirms that a merge train consistently completes and updates the UI', testcase: 'https://gitlab.com/gitlab-org/quality/testcases/-/issues/1608' do
        Runtime::Env.transient_trials.times do |i|
          QA::Runtime::Logger.info("Transient bug test action - Trial #{i}")

          title = "merge train transient bug test #{random_string_for_this_trial}"

          # Create a merge request to be merged to master
          merge_request = Resource::MergeRequest.fabricate_via_api! do |merge_request|
            merge_request.title = title
            merge_request.project = project
            merge_request.description = title
            merge_request.target_new_branch = false
            merge_request.file_name = random_string_for_this_trial
            merge_request.file_content = random_string_for_this_trial
          end

          merge_request.visit!

          Page::MergeRequest::Show.perform do |show|
            check_pipeline_status(show)

            show.merge_via_merge_train
            check_merge_train_starts(show)

            # This is also tested in pipelines_for_merged_results_and_merge_trains_spec.rb as a regular e2e test.
            # That test reloads the page at this point to avoid the problem of the merge status failing to update
            # That's the transient UX issue this test is checking for, so if the MR is merged but the UI still shows the
            # status as unmerged, the test will fail.

            merge_request = project.merge_request_with_title(title)

            expect(merge_request).not_to be_nil, 'There was a problem fetching the merge request'

            # Merge train should start another pipeline and MR won't merged until this is finished
            check_pipeline_status(show)

            # We use the API to wait until the MR has been merged so that we know the UI should be ready to update
            show.wait_until(reload: false) do
              merge_request_state(merge_request) == 'merged'
            end

            expect(show).to be_merged, "Expected content 'The changes were merged' but it did not appear."
          end
        end
      end

      private

      def random_string_for_this_trial
        SecureRandom.hex(8)
      end

      def check_pipeline_status(page_object)
        pipeline_passed = page_object.retry_until(max_attempts: 5, sleep_interval: 5) do
          page_object.has_pipeline_status?('passed')
        end

        expect(pipeline_passed).to be_truthy, 'Expected the merged result pipeline to pass.'
      end

      def check_merge_train_starts(page_object)
        train_started = page_object.wait_until(reload: false) do
          page_object.has_content? 'started a merge train'
        end

        expect(train_started).to be_truthy, 'Expected to have system note indicating merge train has started.'
      end

      def merge_request_state(merge_request)
        Resource::MergeRequest.fabricate_via_api! do |mr|
          mr.project = project
          mr.iid = merge_request[:iid]
        end.state
      end
    end
  end
end
