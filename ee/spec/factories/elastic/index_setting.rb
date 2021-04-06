# frozen_string_literal: true

FactoryBot.define do
  factory :elastic_index_setting, class: 'Elastic::IndexSetting' do
    sequence(:alias_name) { |n| "alias_name_#{n}" }
  end
end
