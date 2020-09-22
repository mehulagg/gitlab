# frozen_string_literal: true

FactoryBot.define do
  factory :bulk_import, class: 'BulkImport' do
    association :user, factory: :user
    source_type { :gitlab }
  end
end
