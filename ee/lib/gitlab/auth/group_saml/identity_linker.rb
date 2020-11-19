# frozen_string_literal: true

module Gitlab
  module Auth
    module GroupSaml
      class IdentityLinker < Gitlab::Auth::Saml::IdentityLinker
        attr_reader :saml_provider

        def initialize(current_user, oauth, session, saml_provider)
          super(current_user, oauth, session)

          @saml_provider = saml_provider
        end

        override :link
        def link
          super

          update_group_membership unless failed?
        end

        protected

        # rubocop: disable CodeReuse/ActiveRecord
        def identity
          @identity ||= current_user.identities.where(provider: :group_saml,
                                                      saml_provider: saml_provider,
                                                      extern_uid: uid.to_s)
                                    .first_or_initialize
        end
        # rubocop: enable CodeReuse/ActiveRecord

        def update_group_membership
          MembershipUpdater.new(current_user, saml_provider, oauth).execute
        end
      end
    end
  end
end
