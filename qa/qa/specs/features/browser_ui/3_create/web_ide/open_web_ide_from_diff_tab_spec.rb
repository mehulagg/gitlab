# frozen_string_literal: true

module QA
  RSpec.describe 'Create' do
    describe 'Open Web IDE from Diff Tab' do
      files = [
          {
              name: 'file1',
              content: 'test1'
          },
          {
              name: 'file2',
              content: 'test2'
          },
          {
              name: 'file3',
              content: 'test3'
          }
      ]

      let(:project) do
        Resource::Project.fabricate_via_api! do |project|
          project.initialize_with_readme = true
        end
      end

      let(:source) do
        Resource::Repository::ProjectPush.fabricate! do |push|
          push.files = files
          push.project = project
          push.branch_name = 'secure-mr'
        end
      end

      let(:merge_request) do
        Resource::MergeRequest.fabricate_via_api! do |mr|
          mr.source = source
          mr.project = project
          mr.source_branch = 'new-mr'
          mr.target_new_branch = false
        end
      end

      before do
        Flow::Login.sign_in

        merge_request.visit!
      end

      it 'opens and edits a multi-file merge request in Web IDE from Diff Tab', testcase: 'https://gitlab.com/gitlab-org/quality/testcases/-/issues/997' do
        Page::MergeRequest::Show.perform do |show|
          show.click_diffs_tab
          show.edit_file_in_web_ide('file1')
        end

        files.each do |files|
          Page::Project::WebIDE::Edit.perform do |ide|
            expect(ide).to have_file(files[:name])
            expect(ide).to have_content(files[:content])
          end
        end

        Page::Project::WebIDE::Edit.perform do |ide|
          ide.delete_file('file1')
          ide.commit_changes
        end

        merge_request.visit!

        Page::MergeRequest::Show.perform do |show|
          show.click_diffs_tab
          expect(show).not_to have_file('file1')
        end
      end
    end
  end
end
