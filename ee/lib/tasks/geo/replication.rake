namespace :geo do
  namespace :replication do
    task pause: :gitlab_environment do
      Geo::ReplicationToggleRequestService.new.execute(enabled: false)
    end

    task resume: :gitlab_environment do
      Geo::ReplicationToggleRequestService.new.execute(enabled: true)
    end
  end
end
