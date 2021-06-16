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

      let!(:production_push) do
        Resource::Repository::Push.fabricate! do |push|
          push.repository_http_uri = project.repository_http_location.uri
          push.branch_name = 'production'
          push.file_name = '.gitlab-ci.yml'
          push.file_content = production_file_content
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

        project.visit!

        Page::Project::Menu.perform(&:go_to_pipeline_editor)
      end

      after do
        project.remove_via_api!
      end

      it 'can switch branches and target branch field updates accordingly', testcase: 'https://gitlab.com/gitlab-org/quality/testcases/-/issues/1856' do
        Page::Project::PipelineEditor::Show.perform do |show|
          show.click_branch_selector_button
          show.select_branch_from_dropdown(production_push.branch_name)
          expect(show.target_branch_name).to eq(production_push.branch_name)
          show.click_branch_selector_button
          show.select_branch_from_dropdown(project.default_branch)
          expect(show.target_branch_name).to eq(project.default_branch)
        end
      end
    end
  end
end
