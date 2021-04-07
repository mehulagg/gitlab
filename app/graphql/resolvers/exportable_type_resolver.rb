# frozen_string_literal: true

module Resolvers
  class ExportableTypeResolver < BaseResolver
    type Types::ExportableEntitiesType.connection_type,
      null: true

    argument :type, [Types::ExportableTypeEnum],
      required: true,
      description: 'What types to list.'

    def resolve(**args)
      puts '*' * 80
      p args
      puts '*' * 80
    end
  end
end
