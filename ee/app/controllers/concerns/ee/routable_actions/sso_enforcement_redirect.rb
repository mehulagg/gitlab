# frozen_string_literal: true

module EE
  module RoutableActions
    class SsoEnforcementRedirect
      include ::Gitlab::Routing
      include ::Gitlab::Utils::StrongMemoize

      attr_reader :routable

      def initialize(routable)
        @routable = routable
      end

      def should_redirect_to_group_saml_sso?(current_user, request)
        return false unless should_process?
        return false unless request.get?

        access_restricted_by_sso?(current_user)
      end

      def sso_redirect_url
        sso_group_saml_providers_url(root_group, url_params)
      end

      def sso_authorize_path
        omniauth_authorize_path(:user, :group_saml, group_path: routable.path, redirect: redirector.redirect_path)
      end

      module ControllerActions
        def self.on_routable_not_found
          lambda do |routable|
            redirector = SsoEnforcementRedirect.new(routable)
            should_redirect = redirector.should_redirect_to_group_saml_sso?(current_user, request)
            user_has_sso_identity = current_user.group_sso?(routable)

            if should_redirect && user_has_sso_identity
              redirect_to redirector.sso_authorize_path
            elsif should_redirect
              redirect_to redirector.sso_redirect_url
            end
          end
        end
      end

      private

      def access_restricted_by_sso?(current_user)
        Ability.policy_for(current_user, routable)&.needs_new_sso_session?
      end

      def should_process?
        group.present?
      end

      def group
        strong_memoize(:group) do
          case routable
          when ::Group
            routable
          when ::Project
            routable.group
          end
        end
      end

      def root_group
        @root_group ||= group.root_ancestor
      end

      def url_params
        {
          token: root_group.saml_discovery_token,
          redirect: redirect_path
        }
      end

      def redirect_path
        "/#{routable.full_path}"
      end
    end
  end
end
