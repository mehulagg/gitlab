# frozen_string_literal: true

namespace :gitlab do
  namespace :bgmigrations do
    desc 'Run background migration scheduler inline'
    task scheduler: :environment do
      10.times do
        puts "Running the scheduler..."
        sleep 10
      end
    end

    desc 'Run background migration job executor inline'
    task executor: :environment do
      10.times do
        puts "Running the executor..."
        sleep 10
      end
    end
  end
end

