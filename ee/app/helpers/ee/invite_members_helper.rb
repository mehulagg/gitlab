# frozen_string_literal: true

module EE
  module InviteMembersHelper
    def dropdown_invite_members_link(form_model)
      link_to invite_members_url(form_model),
              data: { 'track-event': 'click_link', 'track-label': 'invite_members_new_dropdown' } do
        invite_member_link_content
      end
    end

    private

    def invite_members_url(form_model)
      case form_model
      when Project
        project_project_members_path(form_model)
      when Group
        group_group_members_path(form_model)
      end
    end

    def invite_member_link_content
      text = s_('InviteMember|Invite members')

      return text unless experiment_enabled?(:invite_members_new_dropdown)

      "#{text} #{emoji_icon('shaking_hands', 'aria-hidden': true, class: 'gl-font-base gl-vertical-align-baseline')}".html_safe
    end
  end
end
