# frozen_string_literal: true

namespace :gitlab do
  namespace :geo do
    desc 'GitLab | Geo | Check Geo configuration and dependencies'
    task check: :gitlab_environment do
      SystemCheck::RakeTask::GeoTask.run!
    end
  end
end
