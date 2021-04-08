# frozen_string_literal: true

module Resolvers
  class GroupPackagesResolver < PackageBaseResolver
    def ready?(**args)
      context[self.class] ||= { executions: 0 }
      context[self.class][:executions] += 1
      raise GraphQL::ExecutionError, "Packages can be requested only for one group at a time" if context[self.class][:executions] > 1

      super
    end

    def resolve(sort:)
      return unless packages_available?

      ::Packages::GroupPackagesFinder.new(current_user, object,  SORT_TO_PARAMS_MAP[sort]).execute
    end
  end
end
