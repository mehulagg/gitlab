# frozen_string_literal: true

if main_db_config = Gitlab::Application.config.database_configuration[Rails.env]["main"]
  unless main_db_config["migrations_paths"].include?('db/migrate')
    raise "migrations_paths setting for database must be `db/migrate`"
  end
end

if ci_db_config = Gitlab::Application.config.database_configuration[Rails.env]["ci"]
  unless ci_db_config["migrations_paths"].include?('db/ci_migrate')
    raise "migrations_paths setting for ci database must be `db/ci_migrate`"
  end
end
