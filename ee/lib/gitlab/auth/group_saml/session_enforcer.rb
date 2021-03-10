# frozen_string_literal: true

module Gitlab
  module Auth
    module GroupSaml
      class SessionEnforcer
        SESSION_STORE_KEY = :active_group_sso_sign_ins

        def initialize(user, group)
          @user = user
          @group = group
        end

        attr_reader :user, :group

        def access_restricted?
          return false if check_permission

          session = find_session
          return true unless session

          latest_sign_in = session.with_indifferent_access[saml_provider.id]
          return SsoEnforcer::DEFAULT_SESSION_TIMEOUT.ago < latest_sign_in if ::Feature.enabled?(:enforced_sso_expiry, group)

          false
        end

        private

        def check_permissions
          return true if group_permission

          return true unless saml_enforced?

          return true unless git_check_enforced?

          return true if user.auditor?

          return true if group.owned_by?(user)
        end

        def group_permission
          return true unless group
          return true unless group.root_ancestor
          return true unless saml_provider
        end

        def saml_provider
          @saml_provider ||= group.root_ancestor.saml_provider
        end

        def saml_enforced?
          saml_provider.enforced_sso?
        end

        def git_check_enforced?
          saml_provider.git_check_enforced?
        end

        def find_session
          sessions = ActiveSession.list_sessions(user)
          sessions.select do |session|
            Gitlab::NamespacedSessionStore.new(SESSION_STORE_KEY, session.with_indifferent_access)[saml_provider.id]
          end
        end
      end
    end
  end
end
