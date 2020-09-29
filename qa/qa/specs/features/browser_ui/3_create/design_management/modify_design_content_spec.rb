# frozen_string_literal: true

module QA
  RSpec.describe 'Create' do
    context 'Design Management' do
      let(:old_design) do
        Resource::Design.fabricate! do |design|
          design.filename = 'tanuki.jpg'
        end
      end

      let(:new_design) do
        Resource::Design.fabricate! do |design|
          design.update = true
          design.filename = old_design.filename
          design.issue = old_design.issue
        end
      end

      before do
        Flow::Login.sign_in
      end

      it 'user adds a design and modifies it', testcase: 'https://gitlab.com/gitlab-org/quality/testcases/-/issues/273' do
        old_design.issue.visit!

        Page::Project::Issue::Show.perform do |issue|
          expect(issue).to have_created_icon
        end

        new_design.issue.visit!

        Page::Project::Issue::Show.perform do |issue|
          expect(issue).to have_modified_icon
        end
      end
    end
  end
end
