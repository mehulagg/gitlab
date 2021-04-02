# frozen_string_literal: true

ActiveRecord::ConnectionAdapters::SchemaCache.prepend(Gitlab::Database::SchemaCacheWithRenamedTable)
