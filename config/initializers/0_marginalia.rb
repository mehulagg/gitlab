# frozen_string_literal: true

require 'marginalia'

::Marginalia::Comment.extend(::Gitlab::Marginalia::Comment)

# By default, PostgreSQL only tracks the first 1024 bytes of a SQL
# query. Prepending the comment allows us to trace the source of the
# query without having to increase the `track_activity_query_size`
# parameter.
#
# We only enable this in production because a number of tests do string
# matching against the raw SQL, and prepending the comment prevents color
# coding from working in the development log.
Marginalia::Comment.prepend_comment = true if Rails.env.production?
Marginalia::Comment.components = [:application, :controller, :action, :correlation_id, :jid, :job_class]

# As mentioned in https://github.com/basecamp/marginalia/pull/93/files,
# adding :line has some overhead because a regexp on the backtrace has
# to be run on every SQL query. Only enable this in development because
# we've seen it slow things down.
Marginalia::Comment.components << :line if Rails.env.development?

Gitlab::Marginalia.set_application_name

Gitlab::Marginalia.enable_sidekiq_instrumentation
