# frozen_string_literal: true

module QA
  RSpec.describe 'Create' do
    describe 'Multiple file snippet' do
      it 'creates a project snippet with multiple files', testcase: 'https://gitlab.com/gitlab-org/quality/testcases/-/issues/1024' do
        Flow::Login.sign_in

        Resource::ProjectSnippet.fabricate_via_browser_ui! do |snippet|
          snippet.title = 'Project snippet with multiple files'
          snippet.description = 'Snippet description'
          snippet.visibility = 'Private'
          snippet.file_name = '01 file name'
          snippet.file_content = '01 file content'

          # Ten is the limit of files you can have under one snippet at the moment
          snippet.add_files do |files|
            files.append(name: '02 file name', content: '02 file content')
            files.append(name: '03 file name', content: '03 file content')
            files.append(name: '04 file name', content: '04 file content')
            files.append(name: '05 file name', content: '05 file content')
            files.append(name: '06 file name', content: '06 file content')
            files.append(name: '07 file name', content: '07 file content')
            files.append(name: '08 file name', content: '08 file content')
            files.append(name: '09 file name', content: '09 file content')
            files.append(name: '10 file name', content: '10 file content')
          end
        end

        Page::Dashboard::Snippet::Show.perform do |snippet|
          expect(snippet).to have_snippet_title('Project snippet with multiple files')
          expect(snippet).to have_snippet_description('Snippet description')
          expect(snippet).to have_visibility_type(/private/i)
          expect(snippet).to have_file_name('01 file name', 1)
          expect(snippet).to have_file_content('01 file content', 1)
          expect(snippet).to have_file_name('02 file name', 2)
          expect(snippet).to have_file_content('02 file content', 2)
          expect(snippet).to have_file_name('03 file name', 3)
          expect(snippet).to have_file_content('03 file content', 3)
          expect(snippet).to have_file_name('04 file name', 4)
          expect(snippet).to have_file_content('04 file content', 4)
          expect(snippet).to have_file_name('05 file name', 5)
          expect(snippet).to have_file_content('05 file content', 5)
          expect(snippet).to have_file_name('06 file name', 6)
          expect(snippet).to have_file_content('06 file content', 6)
          expect(snippet).to have_file_name('07 file name', 7)
          expect(snippet).to have_file_content('07 file content', 7)
          expect(snippet).to have_file_name('08 file name', 8)
          expect(snippet).to have_file_content('08 file content', 8)
          expect(snippet).to have_file_name('09 file name', 9)
          expect(snippet).to have_file_content('09 file content', 9)
          expect(snippet).to have_file_name('10 file name', 10)
          expect(snippet).to have_file_content('10 file content', 10)
        end
      end
    end
  end
end
