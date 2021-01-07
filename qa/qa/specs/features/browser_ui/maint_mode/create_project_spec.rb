# frozen_string_literal: true

module QA
  RSpec.describe 'Manage', :maint_mode do
    describe 'Project creation' do
      context 'Maintenance Mode enabled' do
        it 'user CANNOT create a new project' do
          Flow::Login.sign_in

          created_project = Resource::Project.fabricate_via_browser_ui! do |project|
            project.name = 'awesome-project'
            project.description = 'create awesome project test'
            # project.standalone = true
          end

          Page::Project::New.perform do |project|
            expect(project).not_to have_content(created_project.name)
            expect(project).not_to have_content(
              /Project \S?awesome-project\S+ was successfully created/
            )
            expect(project).not_to have_content('create awesome project test')
            expect(project).not_to have_content('The repository for this project is empty')
          end
        end

        # context 'An existing project' do
        #   it 'user CAN view an existing project' do
        #   end

        #   it 'user CANNOT edit an existing project' do
        #     Page::Project::Show.perform(&:create_new_file!)

        #     Page::File::Form.perform do |form|
        #       form.add_name('.gitlab/issue_templates/incident.md')
        #       form.add_content(template)
        #       form.add_commit_message('Add Incident template')
        #       form.commit_changes
        #     end
        #   end

        #   it 'user CANNOT delete an existing project' do
        #   end
        # end
      end
    end
  end
end
