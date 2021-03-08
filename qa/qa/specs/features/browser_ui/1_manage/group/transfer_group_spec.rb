# frozen_string_literal: true

module QA
  RSpec.describe 'Manage' do
    describe 'Subgroup transfer between groups' do
      let(:source_group) do
        Resource::Group.fabricate_via_api! do |group|
          group.path = 'source-group'
        end
      end

      let(:target_group) do
        Resource::Group.fabricate_via_api! do |group|
          group.path = "target-group-for-transfer_#{SecureRandom.hex(8)}"
        end
      end

      let(:sub_group_for_transfer) do
        Resource::Group.fabricate_via_api! do |group|
          group.path = "subgroup-for-transfer_#{SecureRandom.hex(8)}"
          group.sandbox = source_group
        end
      end

      before do
        Flow::Login.sign_in
        sub_group_for_transfer.visit!
      end

      it 'user transfers a subgroup between groups',
         testcase: 'https://gitlab.com/gitlab-org/quality/testcases/-/issues/1724' do
        # Retry is needed here as the target group is not avaliable for transfer right away.
        QA::Support::Retrier.retry_on_exception(reload_page: page) do

          Page::Group::Menu.perform(&:click_group_general_settings_item)
          Page::Group::Settings::General.perform do |general|
            general.transfer_group(target_group.path)
          end

          expect(page).to have_text("Group '#{sub_group_for_transfer.path}' was successfully transferred.")
          expect(page.driver.current_url).to include("#{target_group.path}/#{sub_group_for_transfer.path}")
        end
      end
    end
  end
end
