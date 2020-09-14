# frozen_string_literal: true

module QA
  RSpec.describe 'Create', :requires_admin do
    describe 'Multiple file snippet' do
      before do
        Runtime::Feature.enable_and_verify('snippet_multiple_files')
      end

      after do
        Runtime::Feature.disable_and_verify('snippet_multiple_files')
      end

      it 'creates a personal snippet with multiple files', testcase: 'https://gitlab.com/gitlab-org/quality/testcases/-/issues/842' do
        Flow::Login.sign_in

        Page::Main::Menu.perform do |menu|
          menu.go_to_more_dropdown_option(:snippets_link)
        end

        Resource::Snippet.fabricate_via_browser_ui! do |snippet|
          snippet.title = 'Personal snippet with multiple files'
          snippet.description = 'Snippet description'
          snippet.visibility = 'Public'
          snippet.file_name = '1 file name'
          snippet.file_content = '1 file content'
          snippet.add_file = 2
        end

        Page::Dashboard::Snippet::Show.perform do |snippet|
          expect(snippet).to have_snippet_title('Personal snippet with multiple files')
          expect(snippet).to have_snippet_description('Snippet description')
          expect(snippet).to have_visibility_type(/public/i)
          expect(snippet).to have_file_name('1 file name', 1)
          expect(snippet).to have_file_content('1 file content', 1)
          expect(snippet).to have_file_name('2 file name', 2)
          expect(snippet).to have_file_content('2 file content', 2)
          expect(snippet).to have_file_name('3 file name', 3)
          expect(snippet).to have_file_content('3 file content', 3)
        end
      end
    end
  end
end
