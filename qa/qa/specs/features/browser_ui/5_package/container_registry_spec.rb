# frozen_string_literal: true

module QA
  RSpec.describe 'Package', :orchestrated do
    describe 'Self-managed Container Registry', :ssh_tunnel, :orchestrated do
      before do
        Flow::SignUp.disable_sign_ups
      end

      after do
        @runner.remove_via_api!
      end

      it "pushes image and deletes tag", testcase: 'https://gitlab.com/gitlab-org/quality/testcases/-/issues/1743' do
        project = Resource::Project.fabricate_via_api! do |project|
          project.name = 'project-with-registry'
          project.template_name = 'express'
        end

        @runner = Resource::Runner.fabricate! do |runner|
          runner.name = "qa-runner-#{Time.now.to_i}"
          runner.tags = ["runner-for-#{project.name}"]
          runner.executor = :docker
          runner.project = project
          runner.executor_image = 'docker:19.03.12'
        end

        project.visit!

        Resource::Repository::Commit.fabricate_via_api! do |commit|
          commit.project = project
          commit.commit_message = 'Add .gitlab-ci.yml'
          commit.add_files([{
                                file_path: '.gitlab-ci.yml',
                                content:
                                    <<~YAML
                                      image: docker:19.03.12
                                      variables:
                                        DOCKER_TLS_CERTDIR: "/certs"
                                      services:
                                        - docker:19.03.12-dind

                                      build:
                                        stage: build
                                        script:
                                          - docker login -u $CI_REGISTRY_USER -p $CI_REGISTRY_PASSWORD $CI_REGISTRY
                                          - docker build -t $CI_REGISTRY_IMAGE:$CI_COMMIT_REF_SLUG .
                                          - docker push $CI_REGISTRY_IMAGE:$CI_COMMIT_REF_SLUG
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

    describe 'GitLab-managed Container Registry', only: { subdomain: :staging } do
      after do
        @registry&.remove_via_api!
      end

      it 'pushes image and deletes tag', testcase: 'https://gitlab.com/gitlab-org/quality/testcases/-/issues/1699' do
        project = Resource::Project.fabricate_via_api! do |project|
          project.name = 'project-with-registry'
          project.template_name = 'express'
        end

        @registry = Resource::RegistryRepository.fabricate! do |repository|
          repository.name = "#{project.path_with_namespace}"
          repository.project = project
        end

        Flow::Login.sign_in
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
                                          - docker:19.03.12-dind
                                        variables:
                                          IMAGE_TAG: $CI_REGISTRY_IMAGE:$CI_COMMIT_REF_SLUG
                                        script:
                                          - docker login -u $CI_REGISTRY_USER -p $CI_REGISTRY_PASSWORD $CI_REGISTRY
                                          - docker build -t $IMAGE_TAG .
                                          - docker push $IMAGE_TAG
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
          expect(registry).to have_registry_repository(registry.name)

          registry.click_on_image(registry.name)
          expect(registry).to have_tag('master')

          registry.click_delete
          expect(registry).not_to have_tag('master')
        end
      end
    end
  end
end
