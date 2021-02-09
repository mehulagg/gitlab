# frozen_string_literal: true

module EE
  module RootController
    extend ::Gitlab::Utils::Override

    override :redirect_logged_user
    def redirect_logged_user
      case current_user.dashboard
      when 'operations'
        if current_user.can?(:read_operations_dashboard)
          return redirect_to(operations_path)
        end
      end

      super
    end

    override :redirect_to_home_page_url?
    def redirect_to_home_page_url?
      # If a user is not signed-in and tries to access root_path on a Geo
      # secondary node, redirects them to the sign-in page. Don't redirect
      # to the custom home page URL if one is present. Otherwise, it
      # will break the Geo OAuth workflow always redirecting the user to
      # the Geo primary node, which prevents access to the secondary node.
      return false if ::Gitlab::Geo.secondary?

      super
    end
  end
end
