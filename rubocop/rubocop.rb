# rubocop:disable Naming/FileName
require_relative 'cop/gitlab/has_many_through_scope'
require_relative 'cop/gitlab/httparty'
require_relative 'cop/gitlab/module_with_instance_variables'
require_relative 'cop/gitlab/predicate_memoization'
require_relative 'cop/include_sidekiq_worker'
require_relative 'cop/avoid_return_from_blocks'
require_relative 'cop/avoid_break_from_strong_memoize'
require_relative 'cop/line_break_around_conditional_block'
require_relative 'cop/migration/add_column'
require_relative 'cop/migration/add_concurrent_foreign_key'
require_relative 'cop/migration/add_concurrent_index'
require_relative 'cop/migration/add_index'
require_relative 'cop/migration/add_timestamps'
require_relative 'cop/migration/datetime'
require_relative 'cop/migration/hash_index'
require_relative 'cop/migration/remove_column'
require_relative 'cop/migration/remove_concurrent_index'
require_relative 'cop/migration/remove_index'
require_relative 'cop/migration/reversible_add_column_with_default'
require_relative 'cop/migration/safer_boolean_column'
require_relative 'cop/migration/timestamps'
require_relative 'cop/migration/update_column_in_batches'
require_relative 'cop/migration/update_large_table'
require_relative 'cop/project_path_helper'
require_relative 'cop/rspec/env_assignment'
require_relative 'cop/rspec/factories_in_migration_specs'
require_relative 'cop/sidekiq_options_queue'

# rails5 specific cops.
# Remove them when upgraded to rails 5.0.
require_relative 'cop/gitlab/rails5/application_record'
