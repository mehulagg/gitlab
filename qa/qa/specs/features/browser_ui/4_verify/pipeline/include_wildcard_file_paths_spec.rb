# frozen_string_literal: true

require 'faker'

module QA
  RSpec.describe 'Verify', :requires_admin do
    describe 'Include wildcard file paths' do
      let(:feature_flag) { :ci_wildcard_file_paths }

      let(:project) do
        Resource::Project.fabricate_via_api! do |project|
          project.name = 'project-with-pipeline'
        end
      end

      before do
        Runtime::Feature.enable(feature_flag)
        Flow::Login.sign_in
        add_included_files
        add_an_extra_file
        add_main_ci_file
        project.visit!
        Flow::Pipeline.visit_latest_pipeline
      end

      after do
        Runtime::Feature.disable(feature_flag)
      end

      it 'runs the pipeline with composed config', testcase: 'TODO' do
        Page::Project::Pipeline::Show.perform do |pipeline|
          aggregate_failures 'pipeline has all expected jobs' do
            expect(pipeline).to have_job('build')
            expect(pipeline).to have_job('test')
            expect(pipeline).not_to have_job('deploy')
          end
        end
      end

      private

      def add_main_ci_file
        Resource::Repository::Commit.fabricate_via_api! do |commit|
          commit.project = project
          commit.commit_message = 'Add config file'
          commit.add_files([main_ci_file])
        end
      end

      def add_included_files
        Resource::Repository::Commit.fabricate_via_api! do |commit|
          commit.project = project
          commit.commit_message = 'Add files'
          commit.add_files([included_file_1, included_file_2])
        end
      end

      def add_an_extra_file
        Resource::Repository::Commit.fabricate_via_api! do |commit|
          commit.project = project
          commit.commit_message = 'Add an extra file'
          commit.add_files([extra_file])
        end
      end

      def main_ci_file
        {
          file_path: '.gitlab-ci.yml',
          content: <<~YAML
            include: 'configs/*.yml'
          YAML
        }
      end

      def included_file_1
        {
          file_path: 'configs/builds.yml',
          content: <<~YAML
            build:
              stage: build
              script: echo build
          YAML
        }
      end

      def included_file_2
        {
          file_path: 'configs/tests.yml',
          content: <<~YAML
            test:
              stage: test
              script: echo test
          YAML
        }
      end

      def extra_file
        {
          file_path: 'configs/not_included.yaml', # we only include `*.yml` not `*.yaml`
          content: <<~YAML
            deploy:
              stage: deploy
              script: echo deploy
          YAML
        }
      end
    end
  end
end
