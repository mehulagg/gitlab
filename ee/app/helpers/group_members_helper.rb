# frozen_string_literal: true

module GroupMembersHelper
  def clear_ldap_permission_cache_message
    markdown(
      <<-EOT.strip_heredoc
      Be careful, all members of this group (except you)  will have their
      **access level temporarily downgraded** to `Guest`. The next time that a group member
      signs in to GitLab (or after one hour, whichever occurs first) their access level will
      be updated to the one specified on the Group settings page.
      EOT
    )
  end

  def ldap_sync_button_data
    {
      method: :put,
      path: sync_group_ldap_path(@group),
      modal_attributes: {
        message: _("Warning: Synchronizing LDAP removes direct members' access."),
        title: _('Synchronize LDAP'),
        size: 'sm',
        actionPrimary: {
          text: _('Sync LDAP'),
          attributes: [{ variant: 'danger', 'data-qa-selector': 'sync-ldap-confirm-button' }]
        },
        actionSecondary: {
          text: _('Cancel'),
          attributes: [{ variant: 'default' }],
        }
      }.to_json
    }
  end
end
