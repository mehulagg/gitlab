# frozen_string_literal: true

module QA
  RSpec.describe 'Package', :ssh_tunnel, :orchestrated do
    describe 'Container Repository' do
      let(:project) do
        Resource::Project.fabricate_via_api! do |project|
          project.name = 'project-with-registry'
        end
      end

      let!(:runner) do
        Resource::Runner.fabricate! do |runner|
          runner.name = "qa-runner-#{Time.now.to_i}"
          runner.run_untagged = true
          runner.executor = :docker
          runner.project = project
        end
      end

      let(:gitlab_ci_yaml) do
        <<~YAML
          image: docker:stable

          services:
            - name: docker:stable-dind
              command: ["--insecure-registry=gdk.test:5000"] # Only required if the registry is insecure

          stages:
            - build

          build:
            stage: build
            variables:
              DOCKER_TLS_CERTDIR: ""
            script:
              # login only required if `auth_enabled: true`
              - docker login -u "$CI_REGISTRY_USER" -p "$CI_REGISTRY_PASSWORD" "$CI_REGISTRY"
              - docker pull $CI_REGISTRY_IMAGE/$CI_COMMIT_REF_SLUG:$CI_COMMIT_SHA || true
              - docker build -t $CI_REGISTRY_IMAGE/$CI_COMMIT_REF_SLUG:$CI_COMMIT_SHA .
              - docker push $CI_REGISTRY_IMAGE/$CI_COMMIT_REF_SLUG:$CI_COMMIT_SHA
        YAML
      end

      after do
        runner.remove_via_api!
      end

      it "pushes to the container registry" do
        Flow::SignUp.disable_sign_ups
        project.visit!

        Resource::Repository::ProjectPush.fabricate! do |push|
          push.project = project
          push.directory = Pathname
                               .new(__dir__)
                               .join('../../../../fixtures/auto_devops_rack')
          push.commit_message = 'Add rack application'
        end

        Resource::Repository::Commit.fabricate_via_api! do |commit|
          commit.project = project
          commit.commit_message = 'Add .gitlab-ci.yml'
          commit.add_files([{
                                file_path: '.gitlab-ci.yml',
                                content: gitlab_ci_yaml
                            }])
        end

        Resource::Pipeline.fabricate_via_api! do |pipeline|
          pipeline.project = project
        end.visit!

        Page::Project::Pipeline::Show.perform do |pipeline|
          pipeline.click_job('build')
        end

        Page::Project::Job::Show.perform do |job|
          expect(job).to be_successful(timeout: 800)
        end

        Page::Project::Menu.perform(&:click_container_registry_link)

        Page::Project::Registry::Show.perform do |registry|
          expect(registry).to have_image_repository(project.path_with_namespace, "master")
        end
      end
    end
  end
end
