# frozen_string_literal: true

require 'pathname'

module QA
  RSpec.describe 'Secure', :runner do
    describe 'License merge request widget' do
      let(:approved_license_name) { "MIT" }
      let(:denied_license_name) { "Zlib" }
      let(:executor) {"qa-runner-#{Time.now.to_i}"}

      after do
        @runner.remove_via_api!
      end

      before do
        Flow::Login.sign_in

        @project = Resource::Project.fabricate_via_api! do |project|
          project.name = 'license-widget-project'
          project.description = 'License widget test'
        end

        @runner = Resource::Runner.fabricate! do |runner|
          runner.project = @project
          runner.name = executor
          runner.tags = %w[qa test]
        end

        Resource::Repository::ProjectPush.fabricate! do |project_push|
          project_push.project = @project
          project_push.directory = Pathname
            .new(__dir__)
            .join('../../../../../ee/fixtures/secure_license_files')
          project_push.commit_message = 'Create license file'
        end

        @project.visit!
        Page::Project::Menu.perform(&:click_ci_cd_pipelines)
        Page::Project::Pipeline::Index.perform(&:wait_for_latest_pipeline_success)

        @merge_request = Resource::MergeRequest.fabricate_via_api! do |mr|
          mr.project = @project
          mr.source_branch = 'license-management-mr'
          mr.target_branch = 'master'
          mr.target = 'master'
          mr.file_name = 'gl-license-scanning-report.json'
          mr.file_content =
            <<~FILE_UPDATE
            {
              "licenses": [
                {
                  "count": 1,
                  "name": "WTFPL"
                },
                {
                  "count": 1,
                  "name": "MIT"
                },
                {
                  "count": 1,
                  "name": "Zlib"
                }
              ],
              "dependencies": [
                {
                  "license": {
                      "name": "MIT",
                      "url": "http://opensource.org/licenses/mit-license"
                  },
                  "dependency": {
                      "name": "actioncable",
                      "url": "http://rubyonrails.org",
                      "description": "WebSocket framework for Rails.",
                      "paths": [
                          "."
                      ]
                  }
                },
                {
                  "license": {
                      "name": "WTFPL",
                      "url": "http://www.wtfpl.net/"
                  },
                  "dependency": {
                      "name": "wtfpl_init",
                      "url": "https://rubygems.org/gems/wtfpl_init",
                      "description": "Download WTFPL license file and rename to LICENSE.md or something",
                      "paths": [
                          "."
                      ]
                  }
                },
                {
                  "license": {
                      "name": "Zlib",
                      "url": "https://www.zlib.net/"
                  },
                  "dependency": {
                      "name": "zlib",
                      "url": "https://www.zlib.net/",
                      "description": "Ruby interface for the zlib compression/decompression library",
                      "paths": [
                          "."
                      ]
                  }
                }
              ]
            }
            FILE_UPDATE
          mr.target_new_branch = false
        end

        @project.visit!
        Page::Project::Menu.perform(&:click_ci_cd_pipelines)
        Page::Project::Pipeline::Index.perform(&:wait_for_latest_pipeline_success)
      end

      it 'manage licenses from the merge request', testcase: 'https://gitlab.com/gitlab-org/quality/testcases/-/issues/575' do
        @merge_request.visit!

        Page::MergeRequest::Show.perform do |show|
          show.approve_license_with_mr(approved_license_name)
          show.deny_license_with_mr(denied_license_name)

          show.wait_for_license_compliance_report

          expect(show).to have_approved_license approved_license_name
          expect(show).to have_denied_license denied_license_name
        end
      end
    end
  end
end
