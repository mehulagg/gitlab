# frozen_string_literal: true

module QA
  RSpec.describe 'Create' do
    describe 'Snippet repository storage', :requires_admin, :orchestrated, :repository_storage do
      let(:source_storage) { { type: :gitaly, name: 'default' } }
      let(:destination_storage) { { type: :gitaly, name: QA::Runtime::Env.additional_repository_storage } }

      let(:personal_snippet) do
        Resource::Snippet.fabricate_via_api! do |snippet|
          snippet.title = 'Personal snippet to move storage of'
          snippet.file_name = 'original_file'
          snippet.file_content = 'Original file content'
        end
      end

      let(:project_snippet) do
        Resource::ProjectSnippet.fabricate_via_api! do |snippet|
          snippet.title = 'Project snippet to move storage of'
          snippet.file_name = 'original_file'
          snippet.file_content = 'Original file content'
        end
      end

      praefect_manager = Service::PraefectManager.new

      before do
        praefect_manager.gitlab = 'gitlab'
      end

      shared_examples 'snippet repository storage move' do |snippet_type|
        it "moves #{snippet_type} repository from one Gitaly storage to another" do
          expect(snippet_type).to have_file('original_file')
          expect { snippet_type.change_repository_storage(destination_storage[:name]) }.not_to raise_error
          expect { praefect_manager.verify_storage_move(source_storage, destination_storage) }.not_to raise_error

          # verifies you can push commits to the moved snippet
          Resource::Repository::Push.fabricate! do |push|
            push.repository_http_uri = snippet_type.http_url_to_repo
            push.file_name = 'new_file'
            push.file_content = 'new file content'
            push.commit_message = 'Adding a new snippet file'
            push.new_branch = false
          end

          expect(snippet_type).to have_file('original_file')
          expect(snippet_type).to have_file('new_file')
        end
      end

      it_behaves_like 'snippet repository storage move', :personal_snippet
      it_behaves_like 'snippet repository storage move', :project_snippet
    end
  end
end
