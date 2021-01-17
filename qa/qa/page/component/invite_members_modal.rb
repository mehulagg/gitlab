# frozen_string_literal: true

module QA
  module Page
    module Component
      module InviteMembersModal
        extend QA::Page::PageConcern
        include ::QA::Resource::Members

        def self.included(base)
          super

          base.view 'app/assets/javascripts/invite_members/components/invite_members_modal.vue' do
            element :invite_button
          end

          base.view 'app/assets/javascripts/invite_members/components/members_token_select.vue' do
            element :invite_members_input
          end

          base.view 'app/assets/javascripts/invite_members/components/group_select.vue' do
            element :invite_group_input
          end
        end

        def modal_add_member(group_or_project, user, access_level)
          group_or_project.add_member(user, access_level)
        end

        def modal_invite_group(group_or_project, group_name)
          group_or_project.invite_group(group_name)
        end

        def select_user(username)
          find('gl-token-selector-input', text: "@#{username}").click
        end

        def search_and_select(username)
          find('gl-token-selector-input', text: "@#{username}").click
        end

        def within_modal
          page.within('#invite-members-modal') do
            yield
          end
        end
      end
    end
  end
end
