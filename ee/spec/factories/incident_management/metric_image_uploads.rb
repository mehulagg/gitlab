# frozen_string_literal: true

FactoryBot.define do
  factory :metric_image, class: 'IncidentManagement::MetricImage' do
    association :incident, factory: :incident
    file { fixture_file_upload('spec/fixtures/rails_sample.jpg', 'image/jpg') }
    url { generate(:url) }
  end
end
