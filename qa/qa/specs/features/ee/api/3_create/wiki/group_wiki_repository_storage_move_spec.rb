# frozen_string_literal: true

module QA
  RSpec.describe 'Create' do
    describe 'Group Wiki repository storage', :requires_admin, :orchestrated, :repository_storage do
      let(:source_storage) { { type: :gitaly, name: 'default' } }
      let(:destination_storage) { { type: :gitaly, name: QA::Runtime::Env.additional_repository_storage } }

      let(:group) { Resource::Group.fabricate_via_api! }
      let(:wiki) do
        Resource::Wiki::GroupPage.fabricate_via_api! do |wiki|
          wiki.title = 'Wiki page to move storage of'
          wiki.group = group
          wiki.api_client = Runtime::API::Client.as_admin
        end
      end

      praefect_manager = Service::PraefectManager.new

      before do
        praefect_manager.gitlab = 'gitlab'
      end

      it 'moves group Wiki repository from one Gitaly storage to another', testcase: 'https://gitlab.com/gitlab-org/quality/testcases/-/issues/1733' do
        expect(wiki).to have_page('Wiki page to move storage of')

        expect { group.change_repository_storage(destination_storage[:name]) }.not_to raise_error
        expect { praefect_manager.verify_storage_move(source_storage, destination_storage) }.not_to raise_error

        # verifies you can push commits to the moved Wiki
        wiki.visit!

        Resource::Repository::WikiPush.fabricate! do |push|
          push.wiki = wiki
          push.file_name = 'new-page.md'
          push.file_content = 'new page content'
          push.commit_message = 'Adding a new Wiki page'
          push.new_branch = false
        end

        aggregate_failures do
          expect(wiki).to have_page('Wiki page to move storage of')
          expect(wiki).to have_page('new page')
        end
      end
    end
  end
end
