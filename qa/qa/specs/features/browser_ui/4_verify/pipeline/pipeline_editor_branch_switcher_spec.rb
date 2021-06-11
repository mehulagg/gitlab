# frozen_string_literal: true

module QA
  RSpec.describe 'Verify' do
    describe 'Pipeline editor' do
      let(:project) do
        Resource::Project.fabricate_via_api! do |project|
          project.name = "new-project-#{SecureRandom.hex(8)}"
        end
      end

      let!(:commit) do
        Resource::Repository::Commit.fabricate_via_api! do |commit|
          commit.project = project
          commit.commit_message = 'Add .gitlab-ci.yml'
          commit.branch = project.default_branch
          commit.add_files(
            [
              {
                file_path: '.gitlab-ci.yml',
                content: default_file_content
              }
            ]
          )
        end
      end

      let(:default_file_content) do
        <<~YAML
          stages:
            - test
          
          initialize:
            stage: test
            script:
              - echo "initialized in #{project.default_branch}"
        YAML
      end

      let(:production_file_content) do
        <<~YAML
          stages:
            - test
          
          initialize:
            stage: test
            script:
              - echo "initialized in production"
        YAML
      end

      before do
        Flow::Login.sign_in

        Resource::Repository::Push.fabricate! do |push|
          push.repository_http_uri = project.repository_http_location.uri
          push.branch_name = 'production'
          push.file_name = '.gitlab-ci.yml'
          push.file_content = production_file_content
        end

        project.visit!

        Page::Project::Menu.perform(&:go_to_pipeline_editor)
      end

      after do
        project.remove_via_api!
      end

      it 'can switch branches', testcase: 'https://gitlab.com/gitlab-org/quality/testcases/-/issues/tbd' do

        Page::Project::PipelineEditor::Show.perform do |show|
          # show.click_branch_selector_button # this doesn't work for reasons I don't yet understand
          click_button('master') # using capybara code here as a hack until I can fix the above method
          click_on('production')
          # expect target branch to be production
          click_button('production')
          click_on('master')
          # expect target branch to be master
        end
      end
    end
  end
end
