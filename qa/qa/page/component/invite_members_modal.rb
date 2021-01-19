# frozen_string_literal: true

module QA
  module Page
    module Component
      module InviteMembersModal
        extend QA::Page::PageConcern

        def self.included(base)
          super

          base.view 'app/assets/javascripts/invite_members/components/invite_members_modal.vue' do
            element :invite_button
          end

          base.view 'app/assets/javascripts/invite_members/components/members_token_select.vue' do
            element :invite_members_input, /gl-token-selector-input/ # rubocop:disable QA/ElementWithPattern
          end

          base.view 'app/assets/javascripts/invite_members/components/group_select.vue' do
            element :group_select_dropdown
          end
        end

        def add_member(username, access_level = Resource::Members::AccessLevel::DEVELOPER)
          open_invite_members_modal

          click_element :invite_members_input
          fill_in :invite_members_input, with: username

          Support::WaitForRequests.wait_for_requests

          find_element('.gl-avatar-labeled-sublabel', text: username).click

          click_element :invite_button
        end

        def invite_group(group_name, group_access = Resource::Members::AccessLevel::GUEST)
          open_invite_group_modal

          click_element :group_select_dropdown
          fill_in :group_select_dropdown, with: group_name

          Support::WaitForRequests.wait_for_requests

          find_element('.gl-new-dropdown-item-text-primary', text: group_name).click

          click_element :invite_button
        end
      end
    end
  end
end
