# frozen_string_literal: true

FactoryBot.define do
  factory :user_list, parent: :list do
    list_type { :assignee }
    label { nil }
    user
  end

  factory :milestone_list, parent: :list do
    list_type { :milestone }
    label { nil }
    milestone
  end

  factory :iteration_list, parent: :list do
    list_type { :iteration }
    label { nil }
    iteration
  end
end
