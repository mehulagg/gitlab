# frozen_string_literal: true

module Packages
  module FinderHelper
    extend ActiveSupport::Concern

    private

    def packages_visible_to_user(user, within_group:)
      return ::Packages::Package.none unless within_group
      return ::Packages::Package.none unless Ability.allowed?(user, :read_package, within_group)

      projects = ::Project.in_namespace(within_group.self_and_descendants.select(:id))
                          .public_or_visible_to_user(user, ::Gitlab::Access::REPORTER)
      ::Packages::Package.for_projects(projects.select(:id))
    end
  end
end
