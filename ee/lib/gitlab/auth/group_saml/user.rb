# frozen_string_literal: true

module Gitlab
  module Auth
    module GroupSaml
      class User < Gitlab::Auth::OAuth::User
        include ::Gitlab::Utils::StrongMemoize
        extend ::Gitlab::Utils::Override

        attr_accessor :saml_provider
        attr_reader :auth_hash

        override :initialize
        def initialize(auth_hash)
          @auth_hash = AuthHash.new(auth_hash)
        end

        override :find_and_update!
        def find_and_update!
          save("GroupSaml Provider ##{saml_provider.id}")

          # Do not return un-persisted user so user is prompted
          # to sign-in to existing account.
          return unless valid_sign_in?

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

        override :build_new_user
        def build_new_user(skip_confirmation: false)
          super.tap do |user|
            user.provisioned_by_group_id = saml_provider.group_id
            user.skip_confirmation_notification!

            # rubocop:disable GitlabSecurity/PublicSend
            AuthHash::ALLOWED_USER_ATTRIBUTES.each do |attribute|
              next unless value = auth_hash.public_send(attribute)

              user.public_send("#{attribute}=", value)
            end
            # rubocop:enable GitlabSecurity/PublicSend
          end
        end

        override :user_attributes
        def user_attributes
          super.tap do |hash|
            hash[:extern_uid] = auth_hash.uid
            hash[:saml_provider_id] = @saml_provider.id
            hash[:provider] = ::Users::BuildService::GROUP_SAML_PROVIDER
          end
        end

        def update_group_membership
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
