# frozen_string_literal: true

module QA
  RSpec.describe 'Create' do
    context 'Transient tests', :transient do
      let(:project) do
        Resource::Project.fabricate_via_api! do |project|
          project.name = 'project-for-transient-test'
        end
      end

      let(:merge_request) do
        Resource::MergeRequest.fabricate_via_api! do |merge_request|
          merge_request.project = project
          merge_request.title = 'Transient MR'
          merge_request.description = 'detecting transient bugs'
          merge_request.file_content = 'This is a text for transient bugs'
        end
      end

      let(:dev_user) do
        Resource::User.fabricate_via_api! do |user|
          user.username = 'developer_user'
          user.password = 'developer-user-password' # consider reusing GITLAB USERNAME
        end
      end

      before do
        Flow::Login.sign_in(as: dev_user, skip_page_validation: true)

        project.visit!

        Page::Project::Menu.perform(&:click_members)

        Page::Project::Members.perform do |members|
          members.add_member(dev_user.username)
        end

        merge_request.visit!

        Page::MergeRequest::Show.perform do |merge_request|
          merge_request.click_diffs_tab
          merge_request.add_suggestion_to_diff("```suggestion:-0+0
              This is a new suggestion!")
        end

        Flow::Login.sign_in(as: dev_user, skip_page_validation: true)

        merge_request.visit!
      end

    it 'applies a suggestion' do
      # idea,  the repeater parameter could be passed in code or in the command line
      Support::Waiter.repeat_until(max_attempts: 5) do
        Page::MergeRequest::Show.perform do |merge_request|
          merge_request.click_diffs_tab
          merge_request.apply_suggestion
        end
      end
    end

    end
  end
end
