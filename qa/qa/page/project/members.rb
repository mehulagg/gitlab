# frozen_string_literal: true

module QA
  module Page
    module Project
      class Members < Page::Base
        include Page::Component::InviteMembersModal

        view 'app/views/projects/project_members/_team.html.haml' do
          element :members_list
        end

        view 'app/views/projects/project_members/index.html.haml' do
          element :groups_list_tab
        end

        view 'app/assets/javascripts/invite_members/components/invite_members_trigger.vue' do
          element :invite_members_modal_trigger
        end

        view 'app/views/shared/members/_group.html.haml' do
          element :group_row
          element :delete_group_access_link
        end

        def open_invite_members_modal
          click_element :invite_members_modal_trigger
        end

        def select_group(group_name)
          click_element :group_select_field

          search_and_select(group_name)
        end

        def remove_group(group_name)
          click_element :groups_list_tab
          page.accept_alert do
            within_element(:group_row, text: group_name) do
              click_element :delete_group_access_link
            end
          end
        end
      end
    end
  end
end
