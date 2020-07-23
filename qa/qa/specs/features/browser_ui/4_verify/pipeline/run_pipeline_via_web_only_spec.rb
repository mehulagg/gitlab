# frozen_string_literal: true

module QA
  RSpec.describe 'Verify' do
    describe 'Run pipeline', :docker, :runner do
      before(:context) do
        @feature_flag = 'new_pipeline_form'
        @feature_flag_enabled = Runtime::Feature.enabled?(@feature_flag)
        Runtime::Feature.enable_and_verify(@feature_flag) unless @feature_flag_enabled
      end

      after(:context) do
        Runtime::Feature.disable_and_verify(@feature_flag) unless @feature_flag_enabled
      end

      context 'via web only' do
        let(:project) do
          Resource::Project.fabricate_via_api! do |project|
            project.name = 'web-only-pipeline'
          end
        end

        let!(:runner) do
          Resource::Runner.fabricate! do |runner|
            runner.project = project
            runner.name = project.name
            runner.tags = [project.name]
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
                        job1:
                          tags:
                            - #{project.name}
                          script: echo 'OK'
                          only:
                            - web
                      YAML
                  }
              ]
            )
          end
        end

        before do
          Flow::Login.sign_in
          project.visit!
          Page::Project::Menu.perform(&:click_ci_cd_pipelines)
        end

        after do
          runner.remove_via_api!
          Page::Main::Menu.perform(&:sign_out_if_signed_in)
        end

        it 'does not have danger alert' do
          Page::Project::Pipeline::Index.perform do |index|
            expect(index).not_to have_pipeline
            index.click_run_pipeline_button
          end

          Page::Project::Pipeline::New.perform do |new|
            new.click_run_pipeline_button
            expect(new).not_to have_danger_alert
          end
        end
      end
    end
  end
end
