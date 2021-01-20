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
            element :access_level_dropdown
          end

          base.view 'app/assets/javascripts/invite_members/components/group_select.vue' do
            element :group_select_dropdown_search
          end
        end

        def open_invite_members_modal
          click_element :invite_members_modal_trigger
        end

        def open_invite_group_modal
          click_element :invite_group_modal_trigger
        end

        def add_member(username, access_level = Resource::Members::AccessLevel::DEVELOPER)
          open_invite_members_modal

          fill_element :access_level_dropdown, with: access_level

          fill_in 'Search for members to invite', with: username

          Support::WaitForRequests.wait_for_requests

          click_button username

          click_element :invite_button

          Support::WaitForRequests.wait_for_requests

          page.refresh
        end

        def invite_group(group_name, group_access = Resource::Members::AccessLevel::GUEST)
          open_invite_group_modal

          fill_element :access_level_dropdown, with: group_access

          click_button 'Select a group'
          fill_element :group_select_dropdown_search, group_name

          Support::WaitForRequests.wait_for_requests

          click_button group_name

          click_element :invite_button

          Support::WaitForRequests.wait_for_requests

          page.refresh
        end
      end
    end
  end
end
