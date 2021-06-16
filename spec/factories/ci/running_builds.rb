# frozen_string_literal: true

FactoryBot.define do
  factory :ci_running_build, class: 'Ci::RunningBuild' do
    build factory: :ci_build
    project
    runner factory: :ci_runner
    runner_type { :instance_type }

    trait :group_runner do
      runner_type { :group_type }
    end

    trait :project_runner do
      runner_type { :project_type }
    end
  end
end
