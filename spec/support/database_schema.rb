# frozen_string_literal: true

module DatabaseSchemaHelper
  def with_search_paths(connection, search_path)
    saved = connection.schema_search_path
    connection.schema_search_path = search_path
    yield
  ensure
    connection.schema_search_path = saved
  end
end
