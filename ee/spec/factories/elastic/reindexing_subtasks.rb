# frozen_string_literal: true

FactoryBot.define do
  factory :elastic_reindexing_subtask, class: 'Elastic::ReindexingSubtask' do
    association :elastic_reindexing_task, in_progress: false, state: :success
    sequence(:index_name_from) { |n| "old_index_name_#{n}" }
    sequence(:index_name_to) { |n| "new_index_name_#{n}" }
    sequence(:alias_name) { |n| "alias_name_#{n}" }
  end
end
