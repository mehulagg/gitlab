# frozen_string_literal: true

module API
  class LdapGroupLinks < ::API::Base
    before { authenticate! }

    feature_category :authentication_and_authorization

    params do
      requires :id, type: String, desc: 'The ID of a group'
    end
    resource :groups do
      desc 'Get LDAP group links for a group' do
        success EE::API::Entities::LdapGroupLink
      end
      get ":id/ldap_group_links" do
        group = find_group(params[:id])
        authorize! :admin_group, group

        ldap_group_links = group.ldap_group_links

        if ldap_group_links.present?
          present ldap_group_links, with: EE::API::Entities::LdapGroupLink
        else
          render_api_error!('No linked LDAP groups found', 404)
        end
      end

      desc 'Add a linked LDAP group to group' do
        success EE::API::Entities::LdapGroupLink
      end
      params do
        optional 'cn', type: String, desc: 'The CN of a LDAP group'
        optional 'filter', type: String, desc: 'The LDAP user filter'
        requires 'group_access', type: Integer, values: Gitlab::Access.all_values,
                                 desc: 'Level of permissions for the linked LDAP group'
        requires 'provider', type: String, desc: 'The LDAP provider for this LDAP group'
        exactly_one_of :cn, :filter
      end
      post ":id/ldap_group_links" do
        group = find_group(params[:id])
        authorize! :admin_group, group
        break not_found! if params[:filter] && !group.licensed_feature_available?(:ldap_group_sync_filter)

        ldap_group_link = group.ldap_group_links.new(declared_params(include_missing: false))

        if ldap_group_link.save
          present ldap_group_link, with: EE::API::Entities::LdapGroupLink
        else
          render_api_error!(ldap_group_link.errors.full_messages.first, 409)
        end
      end

      desc 'Remove a linked LDAP group from group' do
        detail 'Duplicate. DEPRECATED and will be removed in a later version'
      end
      params do
        requires 'cn', type: String, desc: 'The CN of a LDAP group'
      end
      # rubocop: disable CodeReuse/ActiveRecord
      delete ":id/ldap_group_links/:cn" do
        group = find_group(params[:id])
        authorize! :admin_group, group

        ldap_group_link = group.ldap_group_links.find_by(cn: params[:cn])

        if ldap_group_link
          ldap_group_link.destroy
          no_content!
        else
          render_api_error!('Linked LDAP group not found', 404)
        end
      end
      # rubocop: enable CodeReuse/ActiveRecord

      desc 'Remove a linked LDAP group from group' do
        detail 'Duplicate. DEPRECATED and will be removed in a later version'
      end
      params do
        requires 'cn', type: String, desc: 'The CN of a LDAP group'
        requires 'provider', type: String, desc: 'The LDAP provider for this LDAP group'
      end
      # rubocop: disable CodeReuse/ActiveRecord
      delete ":id/ldap_group_links/:provider/:cn" do
        group = find_group(params[:id])
        authorize! :admin_group, group

        ldap_group_link = group.ldap_group_links.find_by(cn: params[:cn], provider: params[:provider])

        if ldap_group_link
          ldap_group_link.destroy
          no_content!
        else
          render_api_error!('Linked LDAP group not found', 404)
        end
      end
      # rubocop: enable CodeReuse/ActiveRecord

      desc 'Remove a linked LDAP group from group'
      params do
        optional 'cn', type: String, desc: 'The CN of a LDAP group'
        optional 'filter', type: String, desc: 'The LDAP user filter'
        requires 'provider', type: String, desc: 'The LDAP provider for this LDAP group'
        exactly_one_of :cn, :filter
      end
      # rubocop: disable CodeReuse/ActiveRecord
      delete ":id/ldap_group_links" do
        group = find_group(params[:id])
        authorize! :admin_group, group
        break not_found! if params[:filter] && !group.licensed_feature_available?(:ldap_group_sync_filter)

        ldap_group_link = group.ldap_group_links.find_by(declared_params(include_missing: false))

        if ldap_group_link
          ldap_group_link.destroy
          no_content!
        else
          render_api_error!('Linked LDAP group not found', 404)
        end
      end
    end
  end
end
