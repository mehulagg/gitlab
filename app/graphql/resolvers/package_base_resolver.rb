# frozen_string_literal: true

module Resolvers
  class PackageBaseResolver < BaseResolver
    type Types::Packages::PackageType.connection_type, null: true

    argument :sort, Types::Packages::PackageSortEnum,
             description: 'Sort packages by this criteria.',
             required: false,
             default_value: :created_desc

    SORT_TO_PARAMS_MAP = {
      created_desc: { order_by: 'created', sort: 'desc' },
      created_asc: { order_by: 'created', sort: 'asc' },
      name_desc: { order_by: 'name', sort: 'desc' },
      name_asc: { order_by: 'name', sort: 'asc' },
      version_desc: { order_by: 'version', sort: 'desc' },
      version_asc: { order_by: 'version', sort: 'asc' },
      type_desc: { order_by: 'type', sort: 'desc' },
      type_asc: { order_by: 'type', sort: 'asc' }
    }.freeze

    private

    def packages_available?
      ::Gitlab.config.packages.enabled
    end
  end
end
