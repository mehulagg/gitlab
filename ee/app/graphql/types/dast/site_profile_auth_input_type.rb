# frozen_string_literal: true

module Types
  module Dast
    class SiteProfileAuthInputType < BaseInputObject
      graphql_name 'DastSiteProfileAuthInput'
      description 'Input type for DastSiteProfile authentication'

      argument :enabled, GraphQL::BOOLEAN_TYPE,
               required: false,
               description: 'Indicates whether authentication is enabled.'

      argument :url, GraphQL::STRING_TYPE,
               required: false,
               description: 'The URL of the page containing the sign-in HTML ' \
                            'form on the target website.'

      argument :username_field, GraphQL::STRING_TYPE,
               required: false,
               description: 'The name of username field at the sign-in HTML form.'

      argument :password_field, GraphQL::STRING_TYPE,
               required: false,
               description: 'The name of password field at the sign-in HTML form.'

      argument :username, GraphQL::STRING_TYPE,
               required: false,
               description: 'The username to authenticate with on the target website.'

      argument :password, GraphQL::STRING_TYPE,
               required: false,
               description: 'The password to authenticate with on the target website.'
    end
  end
end
