# frozen_string_literal: true

require 'pry-byebug'

module QA
  describe 'Create' do
    context 'Apply suggestion' do
      let!(:api_dev_user) { Runtime::API::Client.new(:gitlab, user: developer_user) }
      let!(:api_admin_user) { Runtime::API::Client.as_admin }
      let!(:developer_user) { Resource::User.fabricate_via_api! { |resource| resource.api_client = api_admin_user } }

      let(:file) { 'README.md' }
      let(:new_branch) { 'new_branch' }
      let(:project) { Resource::Project.fabricate_via_api! { |resource| resource.api_client = api_admin_user } }
      let(:key) { Resource::SSHKey.fabricate_via_api! { |resource| resource.api_client = api_dev_user } }
      let(:merge_request) do
        Resource::MergeRequest.fabricate_via_api! do |mr|
          mr.project = project
          mr.source_branch = new_branch
          mr.no_preparation = true
          mr.api_client = api_dev_user
        end
      end

      def setup_project
        Resource::Repository::ProjectPush.fabricate! do |push|
          push.project = project
        end

        project.add_member(developer_user)

        Resource::Repository::ProjectPush.fabricate! do |push|
          push.project = project
          push.ssh_key = key
          push.user = developer_user
          push.branch_name = new_branch
          push.file_name = file
        end
      end

      before do
        setup_project
      end

      it 'able to apply suggestion' do
        Flow::Login.while_signed_in do
          merge_request.visit!

          Page::MergeRequest::Show.perform do |page|
            binding.pry
          end
        end
      end
    end
  end
end
