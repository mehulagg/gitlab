# frozen_string_literal: true

module DatabaseSchemaHelper
  def with_search_paths(connection, search_path)
    connection.transaction(requires_new: true) do
      connection.schema_search_path = search_path
      yield
    end
  end
end
