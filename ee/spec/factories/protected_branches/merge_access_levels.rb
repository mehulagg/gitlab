# frozen_string_literal: true

FactoryBot.modify do
  factory :protected_branch_merge_access_level, class: 'ProtectedBranch::MergeAccessLevel' do
    user { nil }
    group { nil }
  end
end
