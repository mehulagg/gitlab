# frozen_string_literal: true

module QA
  RSpec.describe 'Create' do
    describe 'Merge request squashing' do
      let(:merge_request) do
        Resource::MergeRequest.fabricate_via_api! do |merge_request|
          merge_request.title = 'Squashing commits'
        end
      end

      before do
        Flow::Login.sign_in

        merge_request.project.visit!

        Resource::Repository::ProjectPush.fabricate! do |push|
          push.project = merge_request.project
          push.commit_message = 'to be squashed'
          push.branch_name = merge_request.source_branch
          push.new_branch = false
          push.file_name = 'other.txt'
          push.file_content = "Test with unicode characters ❤✓€❄"
        end

        merge_request.visit!
      end

      it 'user squashes commits while merging', :can_use_large_setup, testcase: 'https://gitlab.com/gitlab-org/quality/testcases/-/issues/418' do
        Page::MergeRequest::Show.perform do |merge_request_page|
          merge_request_page.retry_on_exception(reload: true) do
            expect(merge_request_page).to have_text('to be squashed')
          end

          merge_request_page.mark_to_squash
          merge_request_page.merge!

          Git::Repository.perform do |repository|
            repository.uri = merge_request.project.repository_http_location.uri
            repository.use_default_credentials
            repository.clone

            expect(repository.commits.size).to eq 3
          end
        end
      end
    end
  end
end
