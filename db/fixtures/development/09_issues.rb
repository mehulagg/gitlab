# frozen_string_literal: true

require './db/fixtures/sidekiq_middleware'

Gitlab::Seeder.quiet do
  Rake::Task["gitlab:seed:issues"].invoke
end
