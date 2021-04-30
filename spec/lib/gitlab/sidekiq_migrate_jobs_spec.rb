# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Gitlab::SidekiqMigrateJobs, :clean_gitlab_redis_queues do
  around do |example|
    Sidekiq::Queue.new('authorized_projects').clear
    Sidekiq::Testing.disable!(&example)
    Sidekiq::Queue.new('authorized_projects').clear
  end

  describe '#execute' do
    it 'foo' do
      AuthorizedProjectsWorker.perform_in(3.hours, 0)
      AuthorizedProjectsWorker.perform_in(3.hours, 0)

      described_class.new('schedule').execute('authorized_projects', 'foo')

      p Sidekiq.redis { |c| c.zrange('schedule', 0, -1, with_scores: true) }
    end
  end
end
