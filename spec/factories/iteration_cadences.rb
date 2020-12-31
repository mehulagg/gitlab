# frozen_string_literal: true

FactoryBot.define do
  sequence(:cadence_sequential_date) do |n|
    n.days.from_now
  end

  factory :iteration_cadence do
    title
    group
    start_date { generate(:cadence_sequential_date) }
  end
end
