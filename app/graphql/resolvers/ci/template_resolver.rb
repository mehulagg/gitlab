# frozen_string_literal: true

module Resolvers
  module Ci
    class TemplateResolver < BaseResolver
      type Types::Ci::TemplateType, null: true

      argument :name, GraphQL::STRING_TYPE, required: true,
        description: 'Name of the template to search for.'

      def resolve(name: nil)
        ::TemplateFinder.new(:gitlab_ci_ymls, object, name: name).execute
      end
    end
  end
end
