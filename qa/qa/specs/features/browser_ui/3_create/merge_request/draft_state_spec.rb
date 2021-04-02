# frozen_string_literal: true

module QA
  RSpec.describe 'Create' do
    describe 'Tagging a merge request with Draft' do
      let(:project) do
        Resource::Project.fabricate_via_api! do |project|
          project.name = 'draft'
        end
      end

      let(:draft_mr) do
        Resource::MergeRequest.fabricate_via_api! do |merge_request|
          merge_request.project = project
        end
      end

      before do
        Flow::Login.sign_in
      end

      it 'prevents the act of merging', testcase: 'https://gitlab.com/gitlab-org/quality/testcases/-/issues/1616' do
        draft_mr.visit!

        Page::MergeRequest::Show.perform(&:edit!)

        Page::MergeRequest::New.perform do |merge_request|
          merge_request.mark_as_draft!
          merge_request.save_changes!
        end

        Page::MergeRequest::Show.perform do |merge_request|
          expect(merge_request).to have_merge_disabled

          merge_request.mark_as_ready!

          expect(merge_request.mergeable?).to be_truthy
        end
      end
    end
  end
end
