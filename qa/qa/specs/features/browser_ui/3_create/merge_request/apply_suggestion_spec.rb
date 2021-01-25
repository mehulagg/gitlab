# frozen_string_literal: true

module QA
  describe 'Create' do
    context 'Apply suggestion' do
      # let!(:dev_user_ssh_key) { Resource::SSHKey.fabricate_via_api! { |resource| resource.api_client = api_dev_user } }
      let(:api_admin_user) { Runtime::API::Client.as_admin }
      let(:api_dev_user) { Runtime::API::Client.new(:gitlab, user: developer_user) }
      let(:developer_user) { Resource::User.fabricate_via_api! { |resource| resource.api_client = api_admin_user } }
      let(:file) { 'README.md' }
      let(:new_branch) { 'new_branch' }
      let(:suggestion) { 'Change to this' }
      let(:project) do
        Resource::Project.fabricate_via_api! do |resource|
          resource.api_client = api_admin_user
          resource.initialize_with_readme = true
        end
      end

      let!(:admin_user_id) do
        admin = QA::Resource::User.new.tap do |user|
          user.username = QA::Runtime::User.admin_username
          user.password = QA::Runtime::User.admin_password
          user.api_client = api_admin_user
        end
        admin.reload!.id
      end
      let(:merge_request) do
        Resource::MergeRequest.fabricate_via_api! do |mr|
          mr.project = project
          mr.source_branch = new_branch
          # mr.no_preparation = true
          mr.api_client = api_dev_user
          mr.assignee_id = admin_user_id
        end
      end

      def setup_project
        # Resource::Repository::ProjectPush.fabricate! do |push|
        #   push.project = project
        # end

        project.add_member(developer_user)

        Resource::Repository::ProjectPush.fabricate! do |push|
          push.project = project
          # push.ssh_key = dev_user_ssh_key
          push.user = developer_user
          push.branch_name = new_branch
          push.file_name = file
        end
      end

      def add_suggestion_to_mr
        merge_request

        Flow::Login.while_signed_in do
          merge_request.visit!

          Page::MergeRequest::Show.perform do |mr|
            mr.click_diffs_tab
            mr.add_comment_to_diff(<<~TXT)
              ```suggestion:-0+0
              #{suggestion}
              ```
            TXT
            mr.comment_now
          end
        end
      end

      def apply_suggestion
        Flow::Login.while_signed_in(as: developer_user) do
          merge_request.visit!

          Page::MergeRequest::Show.perform do |mr|
            mr.apply_suggestion
          end
        end
      end

      def merge
        merge_request.visit!

        Page::MergeRequest::Show.perform do |mr|
          mr.merge!
        end
      end

      before do
        setup_project
      end

      it 'able to apply suggestion' do
        add_suggestion_to_mr
        apply_suggestion

        Flow::Login.sign_in_as_admin

        merge

        project.visit!

        Page::Project::Show.perform do |project_page|
          aggregate_failures do
            expect(project_page).to have_file(file)
            expect(project_page).to have_readme_content(suggestion)
          end
        end
      end
    end
  end
end
