# frozen_string_literal: true

namespace :gitlab do
  namespace :bgmigrations do
    desc 'Run background migration scheduler inline'
    task scheduler: :environment do
      10.times do
        puts "Running the scheduler logic..."
        Gitlab::Database::BackgroundMigration::Scheduler.new.perform
        sleep 10
      end
    end

    desc 'Run background migration job executor inline'
    task executor: :environment do
      loop do
        queue = Sidekiq::Queue.new('background_migration')

        if queue.size == 0
          sleep 10
          next
        end

        # Because I don't know how to operate the queue really :D
        job = queue.to_a.min_by { |job| job.item['created_at'] }

        begin
          clazz = job.item['class'].constantize

          puts "Performing job: #{clazz} with args: #{job.item['args']}"

          clazz.new.perform(*job.item['args'])
        rescue => exception
          puts "ERROR: #{exception}"
        ensure
          job.delete
        end
      end
    end
  end
end

