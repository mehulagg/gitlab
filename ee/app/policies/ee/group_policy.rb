module EE
  module GroupPolicy
    extend ActiveSupport::Concern

    prepended do
      with_scope :subject
      condition(:ldap_synced) { @subject.ldap_synced? }
      condition(:epics_disabled) { !@subject.feature_available?(:epics) }

      rule { reporter }.policy do
        enable :admin_list
        enable :admin_board
        enable :admin_issue
      end

      condition(:can_owners_manage_ldap, scope: :global) do
        ::Gitlab::CurrentSettings.current_application_settings
          .allow_group_owners_to_manage_ldap
      end

      rule { public_group }.enable :read_epic

      rule { logged_in_viewable }.enable :read_epic

      rule { guest }.enable :read_epic

      rule { reporter }.policy do
        enable :create_epic
        enable :admin_epic
        enable :update_epic
        enable :destroy_epic
      end

      rule { auditor }.enable :read_group

      rule { admin | (can_owners_manage_ldap & owner) }.enable :admin_ldap_group_links

      rule { ldap_synced }.prevent :admin_group_member

      rule { ldap_synced & (admin | owner) }.enable :update_group_member

      rule { ldap_synced & (admin | (can_owners_manage_ldap & owner)) }.enable :override_group_member

      rule { epics_disabled }.policy do
        prevent :read_epic
        prevent :create_epic
        prevent :admin_epic
        prevent :update_epic
        prevent :destroy_epic
      end
    end
  end
end
