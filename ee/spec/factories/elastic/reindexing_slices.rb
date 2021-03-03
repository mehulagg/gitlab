# frozen_string_literal: true

FactoryBot.define do
  factory :elastic_reindexing_slice, class: 'Elastic::ReindexingSlice' do
    association :elastic_reindexing_subtask
    sequence(:elastic_task) { |n| "elastic_task_#{n}" }
    sequence(:elastic_slice) { |n| n - 1 }
  end
end
