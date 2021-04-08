# frozen_string_literal: true

module QA
  RSpec.describe 'Verify' do
    describe 'Pipeline creation via editor' do
      let(:project) do
        Resource::Project.fabricate_via_api! do |project|
          project.name = 'new-project'
        end
      end

      let(:gitlab_ci_yaml) {  
        <<~YAML
          image: alpine:latest
  
          stages:
            - test
            - build
            - deploy
            
          prepare:
            script: exit 0
            stage: test
            
          step1:
            script: echo testo
            stage: build
          step2:
            script: echo testo
            stage: build
          step3:
            script: echo testo
            stage: build
            
          step4:
            needs: ['step1', 'step3']
            script: exit 0
            stage: deploy
        YAML
      }

      before do
        Flow::Login.sign_in
        project.visit!
        Page::Project::Menu.perform(&:click_ci_cd_pipelines) # consider switching to `go_to_pipelines_editor`
      end

      after do
        project.remove_via_api!
      end

      it 'Validates a valid CI yaml', testcase: 'https://gitlab.com/gitlab-org/quality/testcases/-/issues/tbd' do
        Page::Project::Menu.perform(&:click_pipelines_editor)
        Page::Project::PipelineEditor::Show.perform do |show|
          show.click_element(:create_new_pipeline_button)
          show.click_element(:editor_tab)
          show.fill_element(:editor_tab, gitlab_ci_yaml) # this doesn't work
        end
      end
    end
  end
end
