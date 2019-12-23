# frozen_string_literal: true

require './db/fixtures/sidekiq_middleware'

::Gitlab::DatabaseImporters::CommonMetrics::Importer.new.execute
