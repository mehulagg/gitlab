# frozen_string_literal: true

require 'faker'

module QA
  RSpec.describe 'Verify', :runner do
    let(:executor) { "qa-runner-#{Faker::Alphanumeric.alphanumeric(8)}" }

    let(:project) do
      Resource::Project.fabricate_via_api! do |project|
        project.name = 'project-with-blocked-pipeline'
      end
    end

    let!(:runner) do
      Resource::Runner.fabricate! do |runner|
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
                file_path: '.gitlab-ci.yml',
                content: <<~YAML
                  test_blocked_pipeline:
                     tags:
                       - #{executor}
                     script: echo 'OK!'
                     only:
                       - merge_requests
                YAML
            ]
        )
      end
    end

    let(:merge_request) do
      Resource::MergeRequest.fabricate_via_api! do |merge_request|
        merge_request.project = project
        merge_request.description = Faker::Lorem.sentence
        merge_request.target_new_branch = false
        merge_request.file_name = 'custom_file.txt'
        merge_request.file_content = Faker::Lorem.sentence
      end
    end

    before do
      Flow::Login.sign_in
      merge_request.visit!
    end

    after do
      runner.remove_via_api!
    end

    context 'When pipeline is blocked' do
      it 'can still merge MR successfully', testcase: 'https://gitlab.com/gitlab-org/quality/testcases/-/issues/971' do
        # to be continued
      end
    end
  end
end
