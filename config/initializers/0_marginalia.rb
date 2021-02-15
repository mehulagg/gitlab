# frozen_string_literal: true

require 'marginalia'

::Marginalia::Comment.extend(::Gitlab::Marginalia::Comment)

# Patch to modify 'Marginalia::ActiveRecordInstrumentation.annotate_sql' method with feature check.
# Orignal Marginalia::ActiveRecordInstrumentation is included to ActiveRecord::ConnectionAdapters::PostgreSQLAdapter in the Marginalia Railtie.
# Refer: https://github.com/basecamp/marginalia/blob/v1.8.0/lib/marginalia/railtie.rb#L67
ActiveRecord::ConnectionAdapters::PostgreSQLAdapter.prepend(Gitlab::Marginalia::ActiveRecordInstrumentation)

# By default, PostgreSQL only tracks the first 1024 bytes of a SQL
# query. Prepending the comment allows us to trace the source of the
# query without having to increase the `track_activity_query_size`
# parameter.
Marginalia::Comment.prepend_comment = true unless Rails.env.test? # Some tests do string matching against raw SQL
Marginalia::Comment.components = [:application, :controller, :action, :correlation_id, :jid, :job_class]

# As mentioned in https://github.com/basecamp/marginalia/pull/93/files,
# adding :line has some overhead because a regexp on the backtrace has
# to be run on every SQL query. Only enable this in development because
# we've seen it slow things down.
Marginalia::Comment.components << :line if Rails.env.development?

Gitlab::Marginalia.set_application_name

Gitlab::Marginalia.enable_sidekiq_instrumentation

Gitlab::Marginalia.set_enabled_from_feature_flag
