# frozen_string_literal: true

module EE
  module AutocompleteController
    def project_groups
      groups = ::Autocomplete::ProjectInvitedGroupsFinder
        .new(current_user, params)
        .execute

      render json: InvitedGroupSerializer.new.represent(groups)
    end

    def project_routes
      routes = ::Autocomplete::RoutesFinder::ProjectsOnly
                 .new(current_user, params)
                 .execute

      render json: RouteSerializer.new.represent(routes)
    end

    def namespace_routes
      routes = ::Autocomplete::RoutesFinder::NamespacesOnly
                 .new(current_user, params)
                 .execute

      render json: RouteSerializer.new.represent(routes)
    end
  end
end
