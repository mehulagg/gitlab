# frozen_string_literal: true

module QA
  RSpec.describe 'Create' do
    describe 'Git push over HTTP', :ldap_no_tls, :maint_mode do
      let(:file_name) { "README-#{SecureRandom.hex(8)}.md" }
      let(:project_name) {'awesome-project-3305715c998a2c91'}
      let(:repo_http_uri) { 'http://192.168.0.175:3000/january-7/alphagroup/awesome-project-3305715c998a2c91.git' }
      let(:content) { '# This is a test project' }

      context 'Maintenance Mode' do
        it 'user CANNOT push code to the repository' do
          Flow::Login.while_signed_in do
            expect do
              push_to_default(file: file_name, content: content, uri: repo_http_uri)
            end.to raise_error(QA::Support::Run::CommandError, /403/)

            Page::Dashboard::Projects.perform do |dashboard|
              dashboard.go_to_project(project_name)
            end

            Page::Project::Show.perform do |project|
              expect(project).not_to have_file(file_name)
              expect(project).to have_content('You are on a read-only GitLab instance')
            end
          end
        end

        # Need to provide project http url if no project resource is created
        def push_to_default(file:, content:, uri: )
          Resource::Repository::ProjectPush.fabricate! do |push|
            push.file_name = file
            push.file_content = content
            push.commit_message = "Add #{file}"
            push.repository_http_uri = repo_http_uri
            push.new_branch = false
            push.branch_name = 'default'
            push.wait_for_push = false
          end
        end
      end
    end
  end
end
