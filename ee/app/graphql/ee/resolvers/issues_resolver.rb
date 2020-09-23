# frozen_string_literal: true

module EE
  module Resolvers
    module IssuesResolver
      extend ActiveSupport::Concern

      prepended do
        argument :iteration_id, ::GraphQL::ID_TYPE.to_list_type,
                 required: false,
                 description: 'Iterations applied to the issue'
      end
    end
  end
end
