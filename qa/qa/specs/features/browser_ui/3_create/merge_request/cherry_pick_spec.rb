# frozen_string_literal: true

module QA
  RSpec.describe 'Create' do
    describe 'Cherry pick a merge request' do
      let(:project) do
        Resource::Project.fabricate_via_api! do |project|
          project.name = 'project'
        end
      end

      let(:merge_request_title) { 'One merge request to rule them all' }
      let(:merge_request_description) { '... to find them, to bring them all, and in the darkness bind them' }

      before do
        Flow::Login.sign_in
      end

      it 'cherry pick a basic merge request', testcase: 'https://gitlab.com/gitlab-org/quality/testcases/-/issues/1616' do
        merge_request = Resource::MergeRequest.fabricate_via_api! do |merge_request|
          merge_request.project = project
          merge_request.title = merge_request_title
          merge_request.description = merge_request_description
        end

        merge_request.visit!

        Page::MergeRequest::Show.perform do |merge_request|
          merge_request.merge!
          merge_request.cherry_pick!
        end
      end
    end
  end
end
