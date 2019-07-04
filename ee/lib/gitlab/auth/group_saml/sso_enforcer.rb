# frozen_string_literal: true

module Gitlab
  module Auth
    module GroupSaml
      class SsoEnforcer
        attr_reader :saml_provider

        def initialize(saml_provider)
          @saml_provider = saml_provider
        end

        def update_session
          sso_state.update_active(DateTime.now)
        end

        def active_session?(user)
          skip_background_session_check = ::Feature.disabled?(:enforced_sso_checks_background_session, saml_provider.group)
          sso_state.active?(user, skip_background_session_check: skip_background_session_check)
        end

        def access_restricted?(user)
          saml_enforced? && !active_session?(user) && ::Feature.enabled?(:enforced_sso_requires_session, group)
        end

        def self.group_access_restricted?(group, user)
          return false unless group
          return false unless ::Feature.enabled?(:enforced_sso_requires_session, group)

          saml_provider = group&.root_ancestor&.saml_provider

          return false unless saml_provider

          new(saml_provider).access_restricted?(user)
        end

        def sso_state
          @sso_state ||= SsoState.new(saml_provider.id)
        end

        private

        def saml_enforced?
          saml_provider&.enforced_sso?
        end

        def group
          saml_provider&.group
        end
      end
    end
  end
end
