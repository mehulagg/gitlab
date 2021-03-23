# frozen_string_literal: true

require 'faker'

module QA
  RSpec.describe 'Verify', :runner, :requires_admin do
    describe 'When user is blocked' do
      let(:executor) { "qa-runner-#{Faker::Alphanumeric.alphanumeric(8)}" }
      let!(:admin_api_client) { Runtime::API::Client.as_admin }
      let!(:user_api_client) { Runtime::API::Client.new(:gitlab, user: user) }

      let(:user) do
        Resource::User.fabricate_via_api! do |resource|
          resource.api_client = admin_api_client
        end
      end

      let(:project) do
        Resource::Project.fabricate_via_api! do |project|
          project.name = 'project-for-canceled-pipeline'
        end
      end

      let!(:runner) do
        Resource::Runner.fabricate_via_api! do |runner|
          runner.project = project
          runner.name = executor
          runner.tags = [executor]
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
                    tags: [#{executor}]
                    script:
                      - sleep 5 # allow enough time to schedule/block user
                      - echo 'OK'
                YAML
              }
            ]
          )
        end
      end

      let(:schedule_pipeline) do
        Resource::PipelineSchedules.fabricate_via_api! do |schedule|
          schedule.api_client = user_api_client
          schedule.project = project
        end
      end

      before do
        project.add_member(user, Resource::Members::AccessLevel::MAINTAINER)
        schedule_pipeline
        Support::Waiter.wait_until { !project.pipeline_schedules.empty? }
      end

      after do
        runner.remove_via_api!
        user.remove_via_api!
      end

      it 'pipeline schedule is canceled', testcase: 'https://gitlab.com/gitlab-org/quality/testcases/-/issues/1730' do
        user.block!

        canceled_schedule = project.pipeline_schedules.first
        expect(canceled_schedule[:active]).not_to be_truthy, "Expected schedule active state to be false - active state #{canceled_schedule[:active]}"
      end
    end
  end
end
