# frozen_string_literal: true

require 'airborne'

module QA
  RSpec.describe 'Package' do
    include Support::Api

    describe 'Container Registry' do
      let(:api_client) { Runtime::API::Client.new(:gitlab) }

      let(:project) do
        Resource::Project.fabricate_via_api! do |project|
          project.name = 'project-with-registry-api'
          project.template_name = 'express'
        end
      end

      let(:gitlab_ci_yml) do
        <<~YAML
          build:
            image: docker:19.03.12
            stage: build
            services:
              - docker:19.03.12-dind
            variables:
              IMAGE_TAG: $CI_REGISTRY_IMAGE:$CI_COMMIT_REF_SLUG
            script:
              - docker login -u $CI_REGISTRY_USER -p $CI_REGISTRY_PASSWORD $CI_REGISTRY
              - docker build -t $IMAGE_TAG .
              - docker push $IMAGE_TAG
        YAML
      end

      before do
        Resource::Repository::Commit.fabricate_via_api! do |commit|
          commit.project = project
          commit.commit_message = 'Add .gitlab-ci.yml'
          commit.add_files([{
                              file_path: '.gitlab-ci.yml',
                              content: gitlab_ci_yaml
                            }])
        end
      end

      it '', testcase: '-' do
        Resource::Pipeline.fabricate_via_api! do |pipeline|
          pipeline.project = project
        end

        Support::Retrier.retry_until(max_duration: 80, sleep_interval: 1) do
          pipeline_succeed?
        end

        registry = Resource::RegistryRepository.fabricate! do |repository|
          repository.name = "#{project.path_with_namespace}"
          repository.project = project
          repository.tag_name = 'master'
        end
        # check tag is pushed
        expect(registry).to have_tag('master')
        # delete tag
        registry.delete_tag('master')
        expect(registry).not_to have_tag('master')
      end

      private

      def pipeline_succeed?
        response = get Runtime::API::Request.new(api_client, "/projects/#{project.id}/pipelines").url
        parse_body(response)[:status] == 'success'
      end
    end
  end
end
