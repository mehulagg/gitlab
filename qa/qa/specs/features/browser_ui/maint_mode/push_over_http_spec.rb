# frozen_string_literal: true

module QA
  RSpec.describe 'Create' do
    describe 'Git push over HTTP', :ldap_no_tls, :maint_mode do
      it 'user CANNOT push code to the repository' do
        Flow::Login.sign_in

        Resource::Repository::ProjectPush.fabricate! do |push|
          push.file_name = 'README.md'
          push.file_content = '# This is a test project'
          push.commit_message = 'Add README.md'
        end.project.visit!

        Page::Project::Show.perform do |project|
          expect(project).not_to have_file('README.md')
          expect(project).not_to have_readme_content('This is a test project')
        end
      end
    end
  end
end
