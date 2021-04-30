# frozen_string_literal: true

module Gitlab
  class SidekiqMigrateJobs
    attr_reader :sidekiq_set

    def initialize(sidekiq_set)
      @sidekiq_set = sidekiq_set
    end

    def execute(source, destination)
      cursor = 0

      begin
        cursor, jobs = Sidekiq.redis { |c| c.zscan(sidekiq_set, cursor) }

        jobs.each do |(job, score)|
          next unless job.include?(source)

          job_hash = Sidekiq.load_json(job)

          next unless job_hash['queue'] == source

          job_hash['queue'] = destination

          Sidekiq.redis do |connection|
            removed = connection.zrem(sidekiq_set, job)
            if removed
              connection.zadd(sidekiq_set, score, Sidekiq.dump_json(job_hash))
            end
          end
        end
      end while cursor.to_i != 0
    end
  end
end
