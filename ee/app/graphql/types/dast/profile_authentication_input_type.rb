# frozen_string_literal: true

module Types
  module Dast
    # rubocop: disable Graphql/AuthorizeTypes
    class ProfileAuthenticationInputType < BaseInputObject
      graphql_name 'DastProfileAuthenticationInput'
      description 'Input type for DastSiteProfile authentication'

      argument :url, GraphQL::STRING_TYPE,
               required: false,
               description: 'The url of the page containing the sign-in HTML ' \
                            'form on the target website.'
    end
  end
end
