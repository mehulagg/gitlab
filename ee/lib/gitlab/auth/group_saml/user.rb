# frozen_string_literal: true

module Gitlab
  module Auth
    module GroupSaml
      class User < Gitlab::Auth::Saml::User
        include ::Gitlab::Utils::StrongMemoize

        attr_reader :auth_hash, :saml_provider

        override :initialize
        def initialize(auth_hash, saml_provider)
          @auth_hash = AuthHash.new(auth_hash)
          @saml_provider = saml_provider
        end

        override :find_and_update!
        def find_and_update!
          save("GroupSaml Provider ##{saml_provider.id}")
          update_group_membership

          gl_user
        end

        override :bypass_two_factor?
        def bypass_two_factor?
          false
        end

        private

        override :gl_user
        def gl_user
          strong_memoize(:gl_user) do
            identity&.user || build_new_user
          end
        end

        def identity
          strong_memoize(:identity) do
            ::Auth::GroupSamlIdentityFinder.new(saml_provider, auth_hash).first
          end
        end

        def update_group_membership
          return unless valid_sign_in?

          MembershipUpdater.new(gl_user, saml_provider, auth_hash).execute
        end

        override :block_after_signup?
        def block_after_signup?
          false
        end
      end
    end
  end
end
