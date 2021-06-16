# frozen_string_literal: true

FactoryBot.define do
  factory :ci_pending_build, class: 'Ci::PendingBuild' do
    build factory: :ci_build
    project
    add_attribute(:protected) { false }

    trait :protected do
      add_attribute(:protected) { true }
    end
  end
end
