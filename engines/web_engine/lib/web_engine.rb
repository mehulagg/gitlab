# frozen_string_literal: true

require "web_engine/engine"

require 'graphiql/rails'
require 'graphlient'
require 'apollo_upload_server'
require 'graphql-docs' if Rails.env.development? || Rails.env.test?

module WebEngine
  # Your code goes here...
end
