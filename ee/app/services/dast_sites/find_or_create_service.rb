# frozen_string_literal: true

module DastSites
  class FindOrCreateService < BaseService
    PermissionsError = Class.new(StandardError)

    def execute!(url:)
      raise PermissionsError, 'Insufficient permissions' unless allowed?

      find_or_create_by!(url)
    end

    private

    def allowed?
      Ability.allowed?(current_user, :create_on_demand_dast_scan, project)
    end

    def find_or_create_by!(url)
      DastSite.safe_find_or_create_by!(project: project, url: url)
    end
  end
end
