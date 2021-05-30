# frozen_string_literal: true

module Nav
  module CurrentUserDropdownHelper
    def current_user_dropdown_view_model(project:, group:)
      menu_sections = []

    end

    private

    def current_user_menu_section
      menu_items = []

      if current_user_menu?(:profile)
        menu_items.push(
          ::Gitlab::Nav::TopNavMenuItem.build(
            id: 'user',
            title: _('View profile'),
            href: url_for(current_user),
            data: { user: current_user.username, testid: 'user-profile-link', qa_selector: 'user_profile_link' }
          )
        )
      end

      if can?(current_user, :update_user_status, current_user)
        menu_items.push(
          ::Gitlab::Nav::TopNavMenuItem.build(
            id: 'status',
            title: update_user_status_title,
          )
        )
      end

      if current_user_menu?(:start_trial)
        menu_items.push(
          ::Gitlab::Nav::TopNavMenuItem.build(
            id: 'start_trial',
            title: s_("CurrentUser|Start an Ultimate trial"),
            href: trials_link_url,
            emoji: 'rocket'
          )
        )
      end

      if current_user_menu?(:settings)
        menu_items.push(
          ::Gitlab::Nav::TopNavMenuItem.build(
            id: 'edit_profile',
            title: s_("CurrentUser|Edit profile"),
            href: profile_path,
            data: { qa_selector: 'edit_profile_link' }
          ),
          ::Gitlab::Nav::TopNavMenuItem.build(
            id: 'preferences',
            title: s_("CurrentUser|Preferences"),
            href: profile_preferences_path
          )
        )
      end

      menu_items.push(buy_pipeline_minutes_menu_item)
    end

    def update_user_status_title
      if show_status_emoji?(current_user.status) || user_status_set_to_busy?(current_user.status)
        s_('SetStatusModal|Edit status')
      else
        s_('SetStatusModal|Set status')
      end
    end

    def current_user_meta(user:)
      {
        username: user.username,
        name: user.name,
        ref: user.to_reference,
        status: status_meta(status: user.status)
      }
    end

    def status_meta(status:)
      return unless status

      {
        busy: user_status_set_to_busy?(status),
        emoji: status.emoji,
        message_html: status.message_html
      }
    end

    def buy_pipeline_minutes_menu_item(project:, namespace:)
      nil
    end
  end
end

Nav::CurrentUserDropdownHelper.prepend_mod
