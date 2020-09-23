# frozen_string_literal: true

FactoryBot.define do
  factory :status_page_published_incident, class: '::StatusPage::PublishedIncident' do
    issue
  end
end
