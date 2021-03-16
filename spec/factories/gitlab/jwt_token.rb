# frozen_string_literal: true

FactoryBot.define do
  factory :jwt_token, class: 'Gitlab::JWTToken' do
    skip_create

    sequence(:access_token_id) { |n| n }
    sequence(:user_id) { |n| n }

    initialize_with { new(access_token_id: access_token_id, user_id: user_id) }

    trait :from_job do
      transient do
        job { association :ci_build, :with_user }
      end

      access_token_id { job.token }
      user_id { job.user.id }
    end

    trait :from_personal_access_token do
      transient do
        personal_access_token { association :personal_access_token }
      end

      access_token_id { personal_access_token.id }
      user_id { personal_access_token.user_id }
    end

    trait :from_deploy_token do
      transient do
        deploy_token { association :deploy_token }
      end

      access_token_id { deploy_token.token }
      user_id { deploy_token.username }
    end
  end
end
