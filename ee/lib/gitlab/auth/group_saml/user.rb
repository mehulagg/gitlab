# frozen_string_literal: true

module Gitlab
  module Auth
    module GroupSaml
      class User
        attr_reader :auth_hash, :saml_provider

        def initialize(auth_hash, saml_provider)
          @auth_hash = auth_hash
          @saml_provider = saml_provider
        end

        def find_and_update!
          update_group_membership

          user_from_identity
        end

        def valid_sign_in?
          user_from_identity.present?
        end

        def bypass_two_factor?
          false
        end

        private

        def identity
          @identity ||= ::Auth::GroupSamlIdentityFinder.new(saml_provider, auth_hash).first
        end

        def user_from_identity
          @user_from_identity ||= identity&.user
        end

        def update_group_membership
          return unless user_from_identity

          MembershipUpdater.new(user_from_identity, saml_provider, auth_hash).execute
        end
      end
    end
  end
end
