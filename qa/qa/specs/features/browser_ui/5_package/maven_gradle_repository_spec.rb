# frozen_string_literal: true

module QA
  RSpec.describe 'Package', :orchestrated, :packages do
    describe 'Maven Repository with Gradle' do
      include Runtime::Fixtures

      let(:group_id) { 'com.gitlab.qa' }
      let(:artifact_id) { 'maven_gradle' }
      let(:package_name) { "#{group_id}/#{artifact_id}".tr('.', '/') }
      let(:auth_token) do
        unless Page::Main::Menu.perform(&:signed_in?)
          Flow::Login.sign_in
        end

        Resource::PersonalAccessToken.fabricate!.access_token
      end

      let(:project) do
        Resource::Project.fabricate_via_api! do |project|
          project.name = 'maven-with-gradle-project'
          project.template_name = 'android'
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

      after do
        runner.remove_via_api!
      end

      it 'publishes a maven package via gradle' do
        uri = URI.parse(Runtime::Scenario.gitlab_address)
        @gitlab_address_with_port = "#{uri.scheme}://#{uri.host}:#{uri.port}"

        Resource::Repository::Push.fabricate! do |push|
          push.repository_http_uri = project.repository_http_location.uri
          push.file_name = 'build.gradle'
          push.file_content = build_gradle
          push.commit_message = 'Add maven with gradle configuration'
          push.new_branch = false
        end

        Resource::Repository::ProjectPush.fabricate! do |push|
          push.project = project
          push.new_branch = false
          push.directory = Pathname
                               .new(__dir__)
                               .join('../../../../fixtures/package_managers')
          push.commit_message = 'Add gitlab-ci file for gradle deploy'
        end

        Resource::Pipeline.fabricate_via_api! do |pipeline|
          pipeline.project = project
        end.visit!

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
      end

      private

      def build_gradle
        <<~EOF
              buildscript {
                  repositories {
                      google()
                      jcenter()

                  }
                  dependencies {
                      classpath 'com.android.tools.build:gradle:3.3.1'
                  }
              }

              allprojects {
                  repositories {
                      google()
                      jcenter()

                  }
              }

              task clean(type: Delete) {
                  delete rootProject.buildDir
              }

              plugins {
                  id 'java'
                  id 'maven-publish'
              }

              publishing {
                  publications {
                      library(MavenPublication) {
                          from components.java
                      }
                  }
                  repositories {
                      maven {
                          url "http:/#{@gitlab_address_with_port}/api/v4/projects/#{project.id}/packages/maven"
                          credentials(HttpHeaderCredentials) {
                              name = "Private-Token"
                              value = #{auth_token}
                          }
                          authentication {
                              header(HttpHeaderAuthentication)
                          }
                      }
                  }
              }
        EOF
      end
    end
  end
end

