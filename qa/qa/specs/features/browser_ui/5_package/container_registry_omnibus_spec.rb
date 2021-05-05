# frozen_string_literal: true

module QA
  RSpec.describe 'Package', :registry do
    describe 'Self-managed Container Registry' do

      let(:project) do
        Resource::Project.fabricate_via_api! do |project|
          project.name = 'project-with-registry'
          project.template_name = 'express'
        end
      end

      let(:runner) do
        Resource::Runner.fabricate! do |runner|
          runner.name = "qa-runner-#{Time.now.to_i}"
          runner.tags = ["runner-for-#{project.name}"]
          runner.executor = :docker
          runner.project = project
          runner.executor_image = 'docker:19.03.12'
        end
      end

      before do
        Flow::Login.sign_in
      end

      after do
        runner.remove_via_api!
      end

      it "pushes image and deletes tag", testcase: 'https://gitlab.com/gitlab-org/quality/testcases/-/issues/1743' do

        project.visit!

        Resource::Repository::Commit.fabricate_via_api! do |commit|
          commit.project = project
          commit.commit_message = 'Add .gitlab-ci.yml'
          commit.add_files([{
                              file_path: '.gitlab-ci.yml',
                              content:
                                  <<~YAML
                                  build:
                                    image: docker:19.03.12
                                    stage: build
                                    services:
                                      - name: docker:19.03.12-dind
                                        command: ["--insecure-registry=$CI_REGISTRY"]
                                    variables:
                                      IMAGE_TAG: $CI_REGISTRY_IMAGE:$CI_COMMIT_REF_SLUG
                                      DOCKER_TLS_CERTDIR: "/certs"
                                    script:
                                      - docker login -u $CI_REGISTRY_USER -p $CI_REGISTRY_PASSWORD $CI_REGISTRY
                                      - docker build -t $IMAGE_TAG .
                                      - docker push $IMAGE_TAG
                                    tags:
                                      - "runner-for-#{project.name}"
                                  YAML
                          }])
        end

        Flow::Pipeline.visit_latest_pipeline

        Page::Project::Pipeline::Show.perform do |pipeline|
          pipeline.click_job('build')
        end

        Page::Project::Job::Show.perform do |job|
          expect(job).to be_successful(timeout: 800)
        end

        Page::Project::Menu.perform(&:go_to_container_registry)

        Page::Project::Registry::Show.perform do |registry|
          expect(registry).to have_registry_repository(project.path_with_namespace)

          registry.click_on_image(project.path_with_namespace)
          expect(registry).to have_tag('master')

          registry.click_delete
          expect(registry).not_to have_tag('master')
        end
      end
    end
  end
end