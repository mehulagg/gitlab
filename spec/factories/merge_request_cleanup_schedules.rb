# frozen_string_literal: true

FactoryBot.define do
  factory :merge_request_cleanup_schedule, class: 'MergeRequest::CleanupSchedule' do
    merge_request
    scheduled_at { 1.day.ago }
    status { :unstarted }

    trait :running do
      status { :running }
    end

    trait :completed do
      status { :completed }
      completed_at { Time.current }
    end

    trait :failed do
      status { :failed }
    end
  end
end
