# frozen_string_literal: true

module QA
  RSpec.describe 'Create', :dr_test1 do
    describe 'GitLab HTTP push' do
      let(:file_name) { 'README.md' }

      context 'git-lfs commit' do
        it 'pushes code to the repository via HTTP' do
          file_content = 'This is a Geo project!'
          lfs_file_display_message = 'The rendered file could not be displayed because it is stored in LFS.'
          project = nil

          Runtime::Browser.visit(:gitlab, Page::Main::Login)
          Page::Main::Login.perform(&:sign_in_using_credentials)

          project = Resource::Project.fabricate_via_api! do |project|
            project.name = 'geo-project'
            project.description = 'Geo test project for http lfs push'
          end

          push = Resource::Repository::ProjectPush.fabricate! do |push|
            push.use_lfs = true
            push.project = project
            push.file_name = file_name
            push.file_content = "# #{file_content}"
            push.commit_message = 'Add README.md'
          end

          expect(push.output).to match(/Locking support detected on remote/)

          # Validate git push worked and file exists with content
          push.project.visit!
          Page::Project::Show.perform do |show|
            expect(page).to have_content(file_name)
            expect(page).to have_content(lfs_file_display_message)
          end
        end
      end
    end
  end
end
