# frozen_string_literal: true

module Resolvers
  class ProjectPackagesResolver < PackageBaseResolver
    def resolve(sort:)
      return unless packages_available?

      ::Packages::PackagesFinder.new(object, SORT_TO_PARAMS_MAP[sort]).execute
    end
  end
end
