# frozen_string_literal: true

module EE
  module SessionsController
    extend ActiveSupport::Concern
    extend ::Gitlab::Utils::Override

    prepended do
      before_action :gitlab_geo_logout, only: [:destroy]
    end

    override :new
    def new
      return super if signed_in?

      if ::Gitlab::Geo.secondary_with_primary?
        current_node_uri = URI(GeoNode.current_node_url)
        state = geo_login_state.encode
        redirect_to oauth_geo_auth_url(host: current_node_uri.host, port: current_node_uri.port, state: state)
      else
        super
      end
    end

    protected

    override :auth_options
    def auth_options
      if params[:trial]
        { scope: resource_name, recall: "trial_registrations#new" }
      else
        super
      end
    end

    private

    def gitlab_geo_logout
      return unless ::Gitlab::Geo.secondary?

      # The @geo_logout_state instance variable is used within
      # ApplicationController#after_sign_out_path_for to redirect
      # the user to the logout URL on the primary after sign out
      # on the secondary.
      @geo_logout_state = geo_logout_state.encode # rubocop:disable Gitlab/ModuleWithInstanceVariables
    end

    def geo_login_state
      ::Gitlab::Geo::Oauth::LoginState.new(return_to: sanitize_redirect(geo_return_to_after_login))
    end

    def geo_logout_state
      ::Gitlab::Geo::Oauth::LogoutState.new(token: session[:access_token], return_to: geo_return_to_after_logout)
    end

    def geo_return_to_after_login
      stored_redirect_uri || ::Gitlab::Utils.append_path(root_url, session[:user_return_to].to_s)
    end

    def geo_return_to_after_logout
      safe_redirect_path_for_url(request.referer)
    end

    override :log_failed_login
    def log_failed_login
      login = request.filtered_parameters.dig('user', 'login')
      audit_event_service = ::AuditEventService.new(login, nil)
      audit_event_service.for_failed_login.unauth_security_event

      super
    end
  end
end
