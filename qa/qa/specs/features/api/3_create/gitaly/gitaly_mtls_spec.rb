# frozen_string_literal: true

module QA
  RSpec.describe 'Create' do
    context 'Gitaly' do
      describe 'Using mTLS', :orchestrated, :mtls do
        it 'is still possible to push to gitaly', testcase: 'https://gitlab.com/gitlab-org/quality/testcases/-/issues/1118' do
          project = Resource::Project.fabricate! do |project|
            project.name = "mTLS"
            project.initialize_with_readme = true
          end
        end
      end
    end
  end
end
