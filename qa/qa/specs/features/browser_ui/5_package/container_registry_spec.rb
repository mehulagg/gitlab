# frozen_string_literal: true

module QA
  RSpec.describe 'Package' do
    describe 'Container Repository', only: { subdomain: :staging } do
      let(:project) do
        Resource::Project.fabricate_via_api! do |project|
          project.name = 'project-with-registry'
          project.template_name = 'express'
        end
      end

      let!(:gitlab_ci_yaml) do
        <<~YAML
          build:
            image: docker:19.03.12
            stage: build
            services:
              - docker:19.03.12-dind
            variables:
              IMAGE_TAG: $CI_REGISTRY_IMAGE:$CI_COMMIT_REF_SLUG
              DOCKER_TLS_CERTDIR: "/certs"
            script:
              - docker login -u $CI_REGISTRY_USER -p $CI_REGISTRY_PASSWORD $CI_REGISTRY
              - docker build -t $IMAGE_TAG .
              - docker push $IMAGE_TAG
        YAML
      end

      it "pushes to the container registry" do
        Flow::Login.sign_in
        project.visit!

        Resource::Repository::Commit.fabricate_via_api! do |commit|
          commit.project = project
          commit.commit_message = 'Add .gitlab-ci.yml'
          commit.add_files([{
                                file_path: '.gitlab-ci.yml',
                                content: gitlab_ci_yaml
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
          expect(registry).to have_image_repository(project.path_with_namespace)
        end
      end
    end
  end
end
