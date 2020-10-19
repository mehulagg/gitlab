# frozen_string_literal: true

FactoryBot.define do
  factory :bulk_import_entity, class: 'BulkImports::Entity' do
    bulk_import

    source_type { :group_entity }
    sequence(:source_full_path) { |n| "source-path-#{n}" }

    sequence(:destination_namespace) { |n| "destination-path-#{n}" }
    destination_name { 'Imported Entity' }

    trait(:group_entity) do
      source_type { :group_entity }
    end

    trait(:project_entity) do
      source_type { :project_entity }
    end
  end
end
