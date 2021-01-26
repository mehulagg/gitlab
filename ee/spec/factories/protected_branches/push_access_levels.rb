# frozen_string_literal: true

FactoryBot.modify do
  factory :protected_branch_push_access_level, class: 'ProtectedBranch::PushAccessLevel' do
    user { nil }
    group { nil }
  end
end
