# frozen_string_literal: true

module Gitlab
  module RackAttack
    module Request
      include Gitlab::Utils::StrongMemoize

      def unauthenticated?
        !(authenticated_user_id([:api, :rss, :ics]) || authenticated_runner_id)
      end

      def authenticated_user_id(request_formats)
        request_authenticator.user(request_formats)&.id
      end

      def authenticated_runner_id
        request_authenticator.runner&.id
      end

      def git_http_request?
        # Do a quick check for `.git` in the route before trying to match the controller
        path.include?('.git') && git_controller_names.include?(controller_name)
      end

      def possibly_authenticated_git_request?
        auth_provided? && git_http_request?
      end

      def api_request?
        path.start_with?('/api')
      end

      def api_internal_request?
        path =~ %r{^/api/v\d+/internal/}
      end

      def health_check_request?
        path =~ %r{^/-/(health|liveness|readiness|metrics)}
      end

      def product_analytics_collector_request?
        path.start_with?('/-/collector/i')
      end

      def should_be_skipped?
        api_internal_request? || health_check_request? || possibly_authenticated_git_request?
      end

      def web_request?
        !api_request? && !health_check_request? && !git_http_request?
      end

      def protected_path?
        !protected_path_regex.nil?
      end

      def protected_path_regex
        path =~ protected_paths_regex
      end

      private

      def request_authenticator
        @request_authenticator ||= Gitlab::Auth::RequestAuthenticator.new(self)
      end

      def protected_paths
        Gitlab::CurrentSettings.current_application_settings.protected_paths
      end

      def protected_paths_regex
        Regexp.union(protected_paths.map { |path| /\A#{Regexp.escape(path)}/ })
      end

      def controller_name
        strong_memoize(:controller_name) do
          Gitlab::Application.routes.recognize_path(path, method: request_method)&.fetch(:controller, nil)
        rescue ActionController::RoutingError
          nil
        end
      end

      def auth_provided?
        auth_request.provided?
      end

      def auth_request
        @auth_request ||= Rack::Auth::Basic::Request.new(env)
      end

      def git_controller_names
        @git_controller_names ||= Repositories::GitHttpClientController.descendants
                                    .map(&:controller_path).to_set
      end
    end
  end
end
::Gitlab::RackAttack::Request.prepend_if_ee('::EE::Gitlab::RackAttack::Request')
