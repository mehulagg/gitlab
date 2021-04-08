# frozen_string_literal: true

module Resolvers
  class ProjectPackagesResolver < PackageBaseResolver
    type Types::Packages::PackageType.connection_type, null: true

    def resolve(sort:)
      return unless packages_available?

      ::Packages::PackagesFinder.new(object, SORT_TO_PARAMS_MAP[sort]).execute
    end
  end
end
