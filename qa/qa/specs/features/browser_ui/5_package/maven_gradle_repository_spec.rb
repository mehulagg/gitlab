# frozen_string_literal: true

module QA
  RSpec.describe 'Package', :orchestrated, :packages do
    describe 'Maven Repository with Gradle' do
      include Runtime::Fixtures

      let(:group_id) { 'com.gitlab.qa' }
      let(:artifact_id) { 'maven_gradle' }
      let(:package_name) { "#{group_id}/#{artifact_id}".tr('.', '/') }
      let(:package_version) { '1.3.7' }

      let(:personal_access_token) { Runtime::Env.personal_access_token }

      let(:package_project) do
        Resource::Project.fabricate_via_api! do |project|
          project.name = 'maven-with-gradle-project'
          project.initialize_with_readme = true
        end
      end

      let(:client_project) do
        Resource::Project.fabricate_via_api! do |client_project|
          client_project.name = 'gradle_client'
          client_project.initialize_with_readme = true
          client_project.group = package_project.group
        end
      end

      let(:package) do
        Resource::Package.new.tap do |package|
          package.name = package_name
          package.project = package_project
        end
      end

      let(:runner) do
        Resource::Runner.fabricate! do |runner|
          runner.name = "qa-runner-#{Time.now.to_i}"
          runner.tags = ["runner-for-#{package_project.group.name}"]
          runner.executor = :docker
          runner.token = package_project.group.runners_token
        end
      end

      let(:gitlab_address_with_port) do
        uri = URI.parse(Runtime::Scenario.gitlab_address)
        "#{uri.scheme}://#{uri.host}:#{uri.port}"
      end

      let(:package_gitlab_ci_file) do
        {
          file_path: '.gitlab-ci.yml',
          content:
              <<~YAML
                deploy:
                  image: gradle:6.5-jdk11
                  script:
                  - 'gradle publish'
                  only:
                  - "#{package_project.default_branch}"
                  tags:
                  - "runner-for-#{package_project.group.name}"
              YAML
        }
      end

      let(:package_build_gradle_file) do
        {
          file_path: 'build.gradle',
          content:
              <<~EOF
                plugins {
                    id 'java'
                    id 'maven-publish'
                }

                publishing {
                    publications {
                        library(MavenPublication) {
                            groupId '#{group_id}'
                            artifactId '#{artifact_id}'
                            version '#{package_version}'
                            from components.java
                        }
                    }
                    repositories {
                        maven {
                            url "#{gitlab_address_with_port}/api/v4/projects/#{package_project.id}/packages/maven"
                            credentials(HttpHeaderCredentials) {
                                name = "Private-Token"
                                value = "#{personal_access_token}"
                            }
                            authentication {
                                header(HttpHeaderAuthentication)
                            }
                        }
                    }
                }
              EOF
        }
      end

      let(:client_gitlab_ci_file) {
        {
          file_path: '.gitlab-ci.yml',
          content:
              <<~YAML
                build:
                  image: gradle:6.5-jdk11
                  script:
                  - 'gradle build'
                  only:
                  - "#{client_project.default_branch}"
                  tags:
                  - "runner-for-#{client_project.group.name}"
              YAML
        }
      }

      let(:client_build_gradle_file) {
        {
          file_path: 'build.gradle',
          content:
              <<~EOF
                plugins {
                    id 'java'
                }

                repositories {
                    maven {
                        url "http://gdk.test:8000/api/v4/projects/#{package_project.id}/packages/maven"
                        name "GitLab"
                        credentials(HttpHeaderCredentials) {
                            name = 'Private-Token'
                            value = "#{personal_access_token}"
                        }
                        authentication {
                            header(HttpHeaderAuthentication)
                        }
                    }
                }

                dependencies {
                    implementation group: '#{group_id}', name: '#{artifact_id}', version: '#{package_version}'
                }
              EOF
        }
      }

      before do
        Flow::Login.sign_in
        runner # force its creation
      end

      after do
        runner.remove_via_api!
        package.remove_via_api!
        package_project.remove_via_api!
        client_project.remove_via_api!
      end

      it 'pushes and pulls a maven package via gradle', testcase: 'https://gitlab.com/gitlab-org/quality/testcases/-/issues/1074' do
        # pushing
        Resource::Repository::Commit.fabricate_via_api! do |commit|
          commit.project = package_project
          commit.commit_message = 'Add .gitlab-ci.yml'
          commit.add_files([package_gitlab_ci_file, package_build_gradle_file])
        end

        package_project.visit!

        Flow::Pipeline.visit_latest_pipeline

        Page::Project::Pipeline::Show.perform do |pipeline|
          pipeline.click_job('deploy')
        end

        Page::Project::Job::Show.perform do |job|
          expect(job).to be_successful(timeout: 800)
        end

        Page::Project::Menu.perform(&:click_packages_link)

        Page::Project::Packages::Index.perform do |index|
          expect(index).to have_package(package_name)

          index.click_package(package_name)
        end

        Page::Project::Packages::Show.perform do |show|
          expect(show).to have_package_info(package_name, package_version)
        end

        # pulling
        Resource::Repository::Commit.fabricate_via_api! do |commit|
          commit.project = client_project
          commit.commit_message = 'Add .gitlab-ci.yml'
          commit.add_files([client_gitlab_ci_file, client_build_gradle_file])
        end

        client_project.visit!

        Flow::Pipeline.visit_latest_pipeline

        Page::Project::Pipeline::Show.perform do |pipeline|
          pipeline.click_job('build')
        end

        Page::Project::Job::Show.perform do |job|
          expect(job).to be_successful(timeout: 800)
        end
      end
    end
  end
end
