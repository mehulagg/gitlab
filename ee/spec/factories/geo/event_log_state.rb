# frozen_string_literal: true

FactoryBot.define do
  factory :geo_event_log_state, class: 'Geo::EventLogState' do
    sequence(:event_id)
  end
end
