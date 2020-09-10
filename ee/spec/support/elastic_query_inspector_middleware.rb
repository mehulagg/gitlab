# frozen_string_literal: true

require 'hashie'

class ElasticQueryInspectorMiddleware < Faraday::Middleware
  def initialize(app, options = {})
    super(app)

    @inspector = options.fetch(:inspector)
    @env = nil
  end

  def call(env)
    @env = env

    return continue! unless is_search?

    query = begin
              payload = Gitlab::Json.parse(env[:request_body])
              payload["query"]
            rescue ::JSON::ParserError
              nil
            end

    return continue! unless query.present?

    query.extend(Hashie::Extensions::DeepFind)
    @inspector.inspect(query)

    continue!
  end

  def continue!
    @app.call(@env)
  end

  def is_search?
    @env.url.path.ends_with?("_search")
  end
end
