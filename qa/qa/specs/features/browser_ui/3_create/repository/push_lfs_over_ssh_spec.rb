# frozen_string_literal: true

module QA
  RSpec.describe 'Create', :dr_test do
    describe 'GitLab LFS SSH push' do
      let(:file_name) { 'README.md' }

      key = nil

      after do
        key&.remove_via_api!
      end

      context 'git-lfs commit' do
        it "pushes code to the repository via SSH" do
          key_title = "SSH LFS #{Time.now.to_f}"
          file_content = 'this is the file content'
          lfs_file_display_message = 'The rendered file could not be displayed because it is stored in LFS.'
          project = nil

          # Create a new SSH key for the user
          key = Resource::SSHKey.fabricate_via_api! do |resource|
            resource.title = key_title
          end

          # Create a new Project
          project = Resource::Project.fabricate_via_api! do |project|
            project.name = 'geo-project'
            project.description = 'Geo test project for SSH LFS push'
          end

          # Perform a git push over SSH directly to the primary
          push = Resource::Repository::ProjectPush.fabricate! do |push|
            push.use_lfs = true
            push.ssh_key = key
            push.project = project
            push.file_name = file_name
            push.file_content = "# #{file_content}"
            push.commit_message = 'Add README.md'
          end

          expect(push.output).to match(/Locking support detected on remote/)

          # Validate git push worked and file exists with content
          push.project.visit!
          Page::Project::Show.perform do |show|
            expect(show).to have_content(file_name)
            expect(show).to have_content(lfs_file_display_message)
          end
        end
      end
    end
  end
end
