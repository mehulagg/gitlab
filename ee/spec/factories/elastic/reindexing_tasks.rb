# frozen_string_literal: true

FactoryBot.define do
  factory :elastic_reindexing_task, class: 'Elastic::ReindexingTask' do
    state { :initial }
    in_progress { true }
    index_name_from { 'old_index_name' }
    index_name_to { 'new_index_name' }

    trait :with_subtask do
      after(:create) do |task|
        create :elastic_reindexing_subtask, elastic_reindexing_task: task
      end
    end
  end
end
