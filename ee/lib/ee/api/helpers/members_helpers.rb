# frozen_string_literal: true

module EE
  module API
    module Helpers
      module MembersHelpers
        extend ActiveSupport::Concern
        extend ::Gitlab::Utils::Override

        prepended do
          params :optional_filter_params_ee do
            optional :with_saml_identity, type: Grape::API::Boolean, desc: "List only members with linked SAML identity"
          end
        end

        override :after_create
        def after_create(source)
          super

          ::Gitlab::Subscription::MaxSeatsUpdater.update(source)
        end

        # rubocop: disable CodeReuse/ActiveRecord
        override :retrieve_members
        def retrieve_members(source, params:, deep: false)
          members = super
          members = members.includes(user: :max_access_level_membership)

          if can_view_group_identity?(source)
            members = members.includes(user: :group_saml_identities)
            if params[:with_saml_identity] && source.saml_provider
              members = members.with_saml_identity(source.saml_provider)
            end
          end

          members
        end
        # rubocop: enable CodeReuse/ActiveRecord

        def can_view_group_identity?(members_source)
          can?(current_user, :read_group_saml_identity, members_source)
        end

        override :create_member
        def create_member(current_user, user, source, params)
          member = source.add_user(user, params[:access_level], current_user: current_user, expires_at: params[:expires_at])

          return false unless member

          log_audit_event(member) if member.persisted? && member.valid?

          member
        end

        def log_audit_event(member)
          ::AuditEventService.new(
            current_user,
            member.source,
            action: :create
          ).for_member(member).security_event
        end
      end
    end
  end
end
