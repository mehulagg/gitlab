# frozen_string_literal: true

FactoryBot.define do
  factory :elastic_reindexing_slice, class: 'Elastic::ReindexingSlice' do
    association :elastic_reindexing_subtask
    sequence(:elastic_slice) { |n| n - 1 }
    sequence(:elastic_max_slice) { 5 }
  end
end
