# frozen_string_literal: true

FactoryBot.define do
  factory :import_entity, class: 'ImportEntity' do
    association :bulk_import, factory: :bulk_import
    type { :group_import }

    sequence(:source_full_path) { |n| "source-path-#{n}" }
    sequence(:destination_full_path) { |n| "destination-path-#{n}" }
    destination_name { 'Imported Entity' }

    trait(:group_import) do
      type { :group_import }
    end

    trait(:project_import) do
      type { :project_import }
    end
  end
end
