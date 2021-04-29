# frozen_string_literal: true

require 'faker'

module QA
  RSpec.describe 'Verify' do
    describe 'Merge train', :runner, :requires_admin do
      # let(:file_name) { Faker::Lorem.word }
      # let(:mr_title) { Faker::Lorem.sentence }
      # let(:executor) { "qa-runner-#{Faker::Alphanumeric.alphanumeric(8)}" }

      # let(:project) do
      #   Resource::Project.fabricate_via_api! do |project|
      #     project.name = 'pipeline-for-merge-train'
      #   end
      # end

      # let!(:runner) do
      #   Resource::Runner.fabricate_via_api! do |runner|
      #     runner.project = project
      #     runner.name = executor
      #     runner.tags = [executor]
      #   end
      # end

      # let!(:original_files) do
      #   Resource::Repository::Commit.fabricate_via_api! do |commit|
      #     commit.project = project
      #     commit.commit_message = 'Add .gitlab-ci.yml'
      #     commit.add_files(
      #       [
      #         {
      #           file_path: '.gitlab-ci.yml',
      #           content: <<~YAML
      #             test_merge_train:
      #               tags:
      #                 - #{executor}
      #               script:
      #                 - sleep 3
      #                 - echo 'OK!'
      #               only:
      #                 - merge_requests
      #           YAML
      #         },
      #         {
      #           file_path: file_name,
      #           content: Faker::Lorem.sentence
      #         }
      #       ]
      #     )
      #   end
      # end

      # let(:user) do
      #   Resource::User.fabricate_via_api! do |resource|
      #     resource.api_client = admin_api_client
      #   end
      # end

      #let!(:user_api_client) { Runtime::API::Client.new(:gitlab, user: user) }
      #let!(:admin_api_client) { Runtime::API::Client.as_admin }

      before(:all) do
        executor = "qa-runner-#{Faker::Alphanumeric.alphanumeric(8)}"

        @user = Resource::User.fabricate_via_api! do |resource|
          resource.api_client = Runtime::API::Client.as_admin
        end

        @project = Resource::Project.fabricate_via_api! do |project|
          project.name = 'pipeline-for-merge-train'
        end

        @runner = Resource::Runner.fabricate_via_api! do |runner|
          runner.project = @project
          runner.name = executor
          runner.tags = [executor]
        end

        @user_api_client = Runtime::API::Client.new(:gitlab, user: @user)
        @file_name = Faker::File.unique.file_name
        @mr_title = Faker::Lorem.sentence

        Runtime::Feature.enable(:invite_members_group_modal, project: @project)

        Flow::Login.sign_in
        @project.visit!
        Flow::MergeRequest.enable_merge_trains
        @project.add_member(@user, Resource::Members::AccessLevel::MAINTAINER)

        Resource::Repository::Commit.fabricate_via_api! do |commit|
          commit.project = @project
          commit.commit_message = 'Add .gitlab-ci.yml'
          commit.add_files(
            [
              {
                file_path: '.gitlab-ci.yml',
                content: <<~YAML
                  test_merge_train:
                    tags:
                      - #{executor}
                    script:
                      - sleep 3
                      - echo 'OK!'
                    only:
                      - merge_requests
                YAML
              },
              {
                file_path: @file_name,
                content: Faker::Lorem.sentence
              }
            ]
          )
        end
      end

      after(:all) do
        @runner.remove_via_api!
        @user.remove_via_api!
        @project.remove_via_api!
      end

      shared_examples 'user starts merge trains' do
        merge_request = Resource::MergeRequest.fabricate_via_api! do |merge_request|
          merge_request.api_client = @user_api_client
          merge_request.title = @mr_title
          merge_request.project = @project
          merge_request.description = Faker::Lorem.sentence
          merge_request.target_new_branch = false
          merge_request.file_name = @file_name
          merge_request.file_content = Faker::Lorem.sentence
        end

        Flow::Login.sign_in(as: @user)
        merge_request.visit!

        Page::MergeRequest::Show.perform do |show|
          show.has_pipeline_status?('passed')
          show.try_to_merge!
        end
      end

      shared_examples 'visit To-Do page after canceling merge request' do
        Page::MergeRequest::Show.perform do |show|
          show.wait_until(max_duration: 90, reload: false) { show.has_content?('removed this merge request from the merge train') }
        end

        Page::Main::Menu.perform do |main|
          main.go_to_page_by_shortcut(:todos_shortcut_button)
        end
      end

      context 'when system cancels a merge request', quarantine: { issue: 'https://gitlab.com/gitlab-org/gitlab/-/issues/324122', type: :bug } do
        it_behaves_like 'user starts merge trains'

        it 'creates a TODO task', testcase: 'https://gitlab.com/gitlab-org/quality/testcases/-/issues/1741' do
          # Create a merge conflict
          Resource::Repository::Commit.fabricate_via_api! do |commit|
            commit.api_client = @user_api_client
            commit.project = @project
            commit.commit_message = 'changing text file'
            commit.update_files(
              [
                {
                  file_path: @file_name,
                  content: 'Has to be different than before.'
                }
              ]
            )
          end

          it_behaves_like 'visit To-Do page after canceling merge request'

          Page::Dashboard::Todos.perform do |todos|
            todos.wait_until(reload: true, sleep_interval: 1) { todos.has_todo_list? }

            expect(todos).to have_latest_todo_item_with_content("Removed from Merge Train:", "#{mr_title}")
          end
        end
      end

      context 'when user cancels a merge request' do
        it_behaves_like 'user starts a merge trains'

        it 'does not create a TODO task', testcase: 'https://gitlab.com/gitlab-org/quality/testcases/-/issues/1741' do
          # Manually try to remove merge request from the trains
          Page::MergeRequest::Show.perform do |show|
            show.cancel_auto_merge!
          end

          it_behaves_like 'visit To-Do page after canceling merge request'

          Page::Dashboard::Todos.perform do |todos|
            expect(todos).not_to have_todo_list, 'This user should not have any to-do item but found at least one!'
          end
        end
      end
    end
  end
end
