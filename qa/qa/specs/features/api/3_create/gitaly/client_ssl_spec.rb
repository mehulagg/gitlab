# frozen_string_literal: true

module QA
  RSpec.describe 'Create' do
    context 'Gitaly', :orchestrated, :client_ssl do
      describe 'Client SSL' do
        it 'connects to gitlab', testcase: '' do
          project = Resource::Project.fabricate_via_browser! do |project|
            project.name = "mTLS"
            project.initialize_with_readme = true
          end
        end
      end
    end
  end
end
