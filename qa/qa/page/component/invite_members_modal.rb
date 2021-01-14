# frozen_string_literal: true

module QA
  module Page
    module Component
      module InviteMembersModal
        extend QA::Page::PageConcern

        def modal_add_member(group_or_project, user, access_level)
          group_or_project.add_member(user, access_level)
        end

        def modal_invite_group(group_or_project, group, group_access)
          group_or_project.invite_group(group, group_access)
        end
      end
    end
  end
end
