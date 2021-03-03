# frozen_string_literal: true

FactoryBot.define do
  factory :elastic_reindexing_task, class: 'Elastic::ReindexingTask' do
    state { :initial }
    in_progress { true }

    trait :with_subtask do
      after(:create) do |task|
        create :elastic_reindexing_subtask, elastic_reindexing_task: task
      end
    end
  end
end
