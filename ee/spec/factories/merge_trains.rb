# frozen_string_literal: true

FactoryBot.define do
  factory :merge_train do
    target_branch { target_project.default_branch }
    target_project factory: :project
    merge_request
    user
    pipeline factory: :ci_pipeline

    trait :idle do
      status { MergeTrain.state_machines[:status].states[:idle].value }
    end

    trait :merged do
      status { MergeTrain.state_machines[:status].states[:merged].value }
    end

    trait :merging do
      status { MergeTrain.state_machines[:status].states[:merging].value }
    end

    trait :stale do
      status { MergeTrain.state_machines[:status].states[:stale].value }
    end

    trait :fresh do
      status { MergeTrain.state_machines[:status].states[:fresh].value }
    end
  end
end
