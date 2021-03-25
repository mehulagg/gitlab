# frozen_string_literal: true

module QA
  RSpec.describe 'Create' do
    describe 'Reverting a merged merge request' do
      let(:project) do
        Resource::Project.fabricate_via_api! do |project|
          project.name = 'revert_test_project'
          project.initialize_with_readme = true
        end
      end

      let(:revertable_merge_request) do
        Resource::MergeRequest.fabricate_via_api! do |merge_request|
          merge_request.project = project
          merge_request.target_new_branch = false
        end
      end

      before do
        Flow::Login.sign_in
      end

      it 'revert a merged merge request with a merge request', testcase: 'https://gitlab.com/gitlab-org/quality/testcases/-/issues/1616' do
        revertable_merge_request.visit!

        Page::MergeRequest::Show.perform do |merge_request|
          merge_request.merge!
          merge_request.revert_with_merge_request!
        end

        Page::MergeRequest::New.perform do |merge_request|
          expect(merge_request).to have_content('successfully')
        end
      end

      it 'revert a merged merge request without a merge request', testcase: 'https://gitlab.com/gitlab-org/quality/testcases/-/issues/1616' do
        revertable_merge_request.visit!

        Page::MergeRequest::Show.perform do |merge_request|
          merge_request.merge!
          merge_request.revert_without_merge_request!
        end

        project.visit!
      end
    end
  end
end
