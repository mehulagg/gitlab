# frozen_string_literal: true

module QA
  RSpec.describe 'Create' do
    describe 'Cherry pick a merge request' do
      let(:project) do
        Resource::Project.fabricate_via_api! do |project|
          project.name = 'project'
          project.initialize_with_readme = true
        end
      end

      let(:feature_mr) do
        Resource::MergeRequest.fabricate_via_api! do |merge_request|
          merge_request.project = project
          merge_request.target_branch = "development"
          merge_request.target_new_branch = true
        end
      end

      before do
        Flow::Login.sign_in
      end

      it 'cherry pick a basic merge request', testcase: 'https://gitlab.com/gitlab-org/quality/testcases/-/issues/1616' do
        feature_mr.visit!

        Page::MergeRequest::Show.perform do |merge_request|
          merge_request.merge!
          merge_request.cherry_pick!
        end

        Page::MergeRequest::New.perform do |merge_request|
          expect(merge_request).to have_content('The merge request has been successfully cherry-picked')
        end
      end
    end
  end
end
