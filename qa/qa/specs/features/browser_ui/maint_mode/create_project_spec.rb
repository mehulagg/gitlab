# frozen_string_literal: true
require 'pry-byebug'

module QA
  RSpec.describe 'Manage', :maint_mode do
    describe 'Project creation' do
      context 'Maintenance Mode enabled' do
        it 'user CANNOT create a new project under an existing group' do
          Flow::Login.while_signed_in do
            Page::Dashboard::Projects.perform(&:go_to_new_project)

            # Pass in GITLAB_NAMESPACE_NAME and GITLAB_SANDBOX_NAME if maintenance mode already enabled
            created_project = Resource::Project.fabricate_via_browser_ui! do |project|
              project.name = 'awesome-project'
              project.description = 'create awesome project test'
              project.standalone = true
            end

            Page::Project::New.perform do |project|
              expect(project).to have_content('You are on a read-only GitLab instance')
              expect(project).not_to have_content(created_project.name)
              expect(project).to have_content('You cannot perform write operations on a read-only instance')
            end
          end
        end

        context 'An existing project' do
          it 'user CAN view but CANNOT edit an existing project' do
            Flow::Login.while_signed_in do
              Page::Dashboard::Projects.perform do |dashboard|
                dashboard.go_to_project('awesome-project-3305715c998a2c91')
              end

              Page::Project::Show.perform(&:go_to_general_settings)

              Page::Project::Settings::Main.perform do |settings|
                settings.rename_project_to('new_name')
                expect(settings).to have_content('You are on a read-only GitLab instance')
                expect(settings).not_to have_content('new_name')
              end
            end
          end

          it 'user CANNOT delete an existing project' do
          end
        end
      end
    end
  end
end
