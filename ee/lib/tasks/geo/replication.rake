# frozen_string_literal: true

namespace :geo do
  namespace :replication do
    task pause: :gitlab_environment do
      Geo::ReplicationToggleRequestService.new(enabled: false).execute
    end

    task resume: :gitlab_environment do
      Geo::ReplicationToggleRequestService.new(enabled: true).execute
    end
  end
end
