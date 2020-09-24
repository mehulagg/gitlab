# frozen_string_literal: true

Gitlab::Seeder.quiet do
  Rake::Task['gitlab:license:load'].invoke('verbose')
end
