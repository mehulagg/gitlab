# frozen_string_literal: true

FactoryBot.define do
  factory :external_status_check, class: 'MergeRequests::ExternalStatusCheck' do
    project
    external_url { FFaker::Internet.http_url }

    sequence :name do |i|
      "rule #{i}"
    end
  end
end
