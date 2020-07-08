# frozen_string_literal: true

RSpec.shared_examples 'update with repository actions' do
  context 'when the repository exists' do
    it 'commits the changes to the repository' do
      existing_blob = snippet.blobs.first
      new_file_name = existing_blob.path + '_new'
      new_content = 'New content'

      update_snippet(params: { content: new_content, file_name: new_file_name })

      aggregate_failures do
        expect(response).to have_gitlab_http_status(:ok)
        expect(snippet.repository.blob_at('master', existing_blob.path)).to be_nil

        blob = snippet.repository.blob_at('master', new_file_name)
        expect(blob).not_to be_nil
        expect(blob.data).to eq(new_content)
      end
    end
  end

  context 'when the repository does not exist' do
    let(:snippet) { snippet_without_repo }

    context 'when update attributes does not include file_name or content' do
      it 'does not create the repository' do
        update_snippet(snippet_id: snippet.id, params: { title: 'foo' })

        expect(snippet.repository).not_to exist
      end
    end

    context 'when update attributes include file_name or content' do
      it 'creates the repository' do
        update_snippet(snippet_id: snippet.id, params: { title: 'foo', file_name: 'foo' })

        expect(snippet.repository).to exist
      end

      it 'commits the file to the repository' do
        content = 'New Content'
        file_name = 'file_name.rb'

        update_snippet(snippet_id: snippet.id, params: { content: content, file_name: file_name })

        blob = snippet.repository.blob_at('master', file_name)
        expect(blob).not_to be_nil
        expect(blob.data).to eq content
      end

      context 'when save fails due to a repository creation error' do
        let(:content) { 'File content' }
        let(:file_name) { 'test.md' }

        before do
          allow_next_instance_of(Snippets::UpdateService) do |instance|
            allow(instance).to receive(:create_repository_for).with(snippet).and_raise(Snippets::UpdateService::CreateRepositoryError)
          end

          update_snippet(snippet_id: snippet.id, params: { content: content, file_name: file_name })
        end

        it 'returns 400' do
          expect(response).to have_gitlab_http_status(:bad_request)
        end

        it 'does not save the changes to the snippet object' do
          expect(snippet.content).not_to eq(content)
          expect(snippet.file_name).not_to eq(file_name)
        end
      end
    end
  end
end

RSpec.shared_examples 'snippet blob content' do
  it 'returns content from repository' do
    subject

    expect(response.body).to eq(snippet.blobs.first.data)
  end

  context 'when snippet repository is empty' do
    let(:snippet) { snippet_with_empty_repo }

    it 'returns content from database' do
      subject

      expect(response.body).to eq(snippet.content)
    end
  end
end

RSpec.shared_examples 'snippet_multiple_files feature disabled' do
  before do
    stub_feature_flags(snippet_multiple_files: false)

    subject
  end

  it 'does not return files attributes' do
    expect(json_response).not_to have_key('files')
  end
end
