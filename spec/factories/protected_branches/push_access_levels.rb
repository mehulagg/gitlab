FactoryBot.define do
  factory :protected_branch_push_access_level, class: ProtectedBranch::PushAccessLevel do
    user nil
    group nil
    protected_branch
    access_level { Gitlab::Access::DEVELOPER }
  end
end
