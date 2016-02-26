module Gitlab
  module LDAP
    class GroupSync

      def initialize(adapter=nil)
        @adapter = adapter
      end

      def providers
        Gitlab::LDAP::Config.providers
      end


      # TODO: Update the docs
      # Loop through all ldap connected groups, and update the users link with it
      #
      # We documented what sort of queries an LDAP server can expect from
      # GitLab EE in doc/integration/ldap.md. Please remember to update that
      # documentation if you change the algorithm below.


      def update_permissions
        providers.each do |provider|
          config = Gitlab::LDAP::Config.new(provider)
          adapter = Gitlab::LDAP::Adapter.new(provider)

          if config.group_base.present?
            groups = gitlab_groups_with_ldap_link(provider)

            logger.debug "Performing LDAP group sync for '#{provider}' provider"
            sync_groups(groups, provider, adapter)
            logger.debug "Finished LDAP group sync for '#{provider} provider'"
          else
            logger.debug "No `group_base` configured for '#{provider}' provider. Skipping"
          end

          if config.admin_group.present?
            logger.debug "Syncing admin users for '#{provider}' provider"
            sync_admin_users(config.admin_group, provider, adapter)
            logger.debug "Finished syncing admin users for '#{provider} provider'"
          else
            logger.debug "No `admin_group` configured for '#{provider}' provider. Skipping"
          end
        end

        nil
      end

      def sync_groups(groups, provider, adapter)
        groups.each do |group|
          access_hash = {}
          group_links = group.ldap_group_links

          logger.debug "Syncing '#{group.name}' group"

          group_links.each do |group_link|

            ldap_group = Gitlab::LDAP::Group.find_by_cn(group_link.cn, adapter)
            member_dns = ldap_group_members(ldap_group)
            members_to_access_hash(
              access_hash, member_dns, group_link.group_access
            )

            logger.debug "Resolved '#{group.name}' group member access: #{access_hash}"
          end

          update_existing_group_membership(group, access_hash, provider)
          add_new_members(group, access_hash, provider)

          logger.debug "Finished syncing '#{group.name}' group"
        end
      end


      def sync_admin_users(admin_group_cn, provider, adapter)
        admin_group = Gitlab::LDAP::Group.find_by_cn(admin_group_cn, adapter)
        admin_group_member_dns = ldap_group_members(admin_group)
        current_admin_users = ::User.admins
                                .includes(:identities).references(:identities)
                                .where(identities: { provider: provider })
        verified_admin_users = []

        # Verify existing admin users and add new ones.
        admin_group_member_dns.each do |member_dn|
          user = find_user_by_dn_and_provider(member_dn, provider)

          if user.present?
            user.admin = true
            user.save
            verified_admin_users << user
          else
            logger.debug <<-MSG.strip_heredoc.gsub(/\n/, ' ')
              #{self.class.name}: User with DN `#{member_dn}` should have admin
              access but there is no user in GitLab with that identity.
              Membership will be updated once the user signs in for the first time.
            MSG
          end
        end

        # Revoke the unverified admins.
        current_admin_users.each do |user|
          unless verified_admin_users.include?(user)
            user.admin = false
            user.save
          end
        end
      end

      private

      def ldap_group_members(ldap_group)
        member_dns = ldap_group.member_dns
        if member_dns.empty?
          member_dns = ldap_group.member_uids
          # TODO: Do something else here, to get full DNs or user object?
        end
        return [] if member_dns.empty?

        logger.debug "Members in '#{ldap_group.name}' LDAP group: #{member_dns}"

        member_dns
      end

      def update_existing_group_membership(group, access_hash, provider)
        logger.debug "Updating existing membership for '#{group.name}' group"

        group.members.each do |member|
          user = member.user
          identity = user.identities.where(provider: provider) if user.present?
          member_dn = identity.first.extern_uid if identity.present?
          desired_access = access_hash[member_dn]

          # Skip if this is not an LDAP user with a valid `extern_uid`.
          next unless member_dn.present?

          # Don't do anything if the user already has the desired access level
          next if member.access_level == desired_access

          # Check and update the access level. If `desired_access` is `nil`
          # we need to delete the user from the group.
          if desired_access.present?
            user = member.user
            add_or_update_user_membership(user, group, desired_access)

            # Delete this entry from the hash now that we've acted on it
            access_hash.delete(member_dn)
          elsif group.last_owner?(user)
            warn_cannot_remove_last_owner(user, group)
          else
            group.users.delete(user)
          end
        end
      end

      def add_new_members(group, access_hash, provider)
        logger.debug "Adding new members to '#{group.name}' group"

        access_hash.each do |member_dn, access_level|
          user = find_user_by_dn_and_provider(member_dn, provider)

          if user.present?
            group.add_users([user.id], access_level, skip_notification: true)
          else
            logger.debug <<-MSG.strip_heredoc.gsub(/\n/, ' ')
              #{self.class.name}: User with DN `#{member_dn}` should have access
              to '#{group.name}' group but there is no user in GitLab with that
              identity. Membership will be updated once the user signs in for
              the first time.
            MSG
          end
        end
      end

      def add_or_update_user_membership(user, group, access)
        # Prevent the last owner of a group from being demoted
        if access != Gitlab::Access::OWNER && group.last_owner?(user)
          warn_cannot_remove_last_owner(user, group)
        else
          group.add_users([user.id], access, skip_notification: true)
        end
      end

      def warn_cannot_remove_last_owner(user, group)
        logger.warn <<-MSG.strip_heredoc.gsub(/\n/, ' ')
          #{self.class.name}: LDAP group sync cannot remove #{user.name}
          (#{user.id}) from group #{group.name} (#{group.id}) as this is
          the group's last owner
        MSG
      end

      def members_to_access_hash(access_hash, member_dns, group_access)
        member_dns.each do |member_dn|
          current_access_hash_value = access_hash[member_dn]
          if current_access_hash_value.present?
            # Keep the higher of the access values
            if group_access > current_access_hash_value
              access_hash[member_dn] = group_access
            end
          else
            access_hash[member_dn] = group_access
          end
        end
        access_hash
      end

      def group_links(provider)
        LdapGroupLink.with_provider(provider)
      end

      def ldap_groups(group_links)
        group_links.distinct(:cn).pluck(:cn).map do |cn|
          Gitlab::LDAP::Group.find_by_cn(cn, adapter)
        end.compact
      end

      def gitlab_groups_with_ldap_link(provider)
        ::Group.includes(:ldap_group_links).references(:ldap_group_links).
          where.not(ldap_group_links: { id: nil }).
          where(ldap_group_links: { provider: provider })
      end

      def find_user_by_dn_and_provider(dn, provider)
        user = ::User
                 .includes(:identities).references(:identities)
                 .where(
                   identities: { provider: provider, extern_uid: dn }
                 )

        if user.count > 1
          logger.warn <<-MSG.strip_heredoc.gsub(/\n/, ' ')
            #{self.class.name}: Found more than one user with identity
            where provider is '#{provider}' and extern_uid is '#{dn}'.
            Only one result expected.
          MSG

          # TODO: Raise an exception here? This **shouldn't** happen. If it
          # does, do we want to halt the entire process?
          nil
        else
          user.first
        end
      end

      def logger
        Rails.logger
      end
    end
  end
end
