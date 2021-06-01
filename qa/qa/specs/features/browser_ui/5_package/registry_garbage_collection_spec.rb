# frozen_string_literal: true

module QA
  RSpec.describe 'Package' do
    describe 'Container Registry Garbage Collection', :registry_gc, only: { subdomain: %i[pre] } do
      let(:project) do
        Resource::Project.fabricate_via_api! do |project|
          project.name = 'project-for-garbage-collection'
        end
      end

      let!(:gitlab_ci_yaml) do
        <<~YAML
          cache:
            key: ${CI_COMMIT_SHA}
            paths:
              - .online-gc-tester/
              - .go/pkg/mod/
        
          variables:
            GOPATH: $CI_PROJECT_DIR/.go
            BUILD_CACHE: $CI_PROJECT_DIR/.online-gc-tester
          
          default:
            tags:
              - gitlab-org
          
          stages:
            - generate
            - build
            - validate
          
          .docker-and-go: &docker-and-go
            image: docker:19
            services:
              - docker:19-dind
            before_script:
              - apk add go
              - mkdir -p $GOPATH
              - mkdir -p $BUILD_CACHE
          
          generate:
            stage: generate
            extends: .docker-and-go
            script:
              - go run ./main.go generate -d=$BUILD_CACHE
          
          build:
            stage: build
            extends: .docker-and-go
            needs: [ generate ]
            script:
              - go run ./main.go build -d=$BUILD_CACHE
              - go run ./main.go push -d=$BUILD_CACHE
          
          validate:
            stage: validate
            extends: .docker-and-go
            needs: [ build ]
            script:
              - go run ./main.go pull -d=$BUILD_CACHE
        YAML
      end

      before do
        Resource::Repository::ProjectPush.fabricate! do |push|
          push.project = project
          push.directory = Pathname
            .new(__dir__)
            .join('../../../../fixtures/gc_tool')
          push.commit_message = 'Online garbage collection tester'
        end
      end

      it 'runs garbage collector' do
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
          pipeline.click_job('generate')
        end

        Page::Project::Job::Show.perform do |job|
          expect(job).to be_successful(timeout: 900) # 15 minutes
        end

        Flow::Pipeline.visit_latest_pipeline

        Page::Project::Pipeline::Show.perform do |pipeline|
          pipeline.click_job('build')
        end

        Page::Project::Job::Show.perform do |job|
          expect(job).to be_successful(timeout: 900) 
        end

        Flow::Pipeline.visit_latest_pipeline

        Page::Project::Pipeline::Show.perform do |pipeline|
          pipeline.click_job('validate')
        end

        Page::Project::Job::Show.perform do |job|
          expect(job).to be_successful(timeout: 900) 
        end
      end
    end
  end
end
