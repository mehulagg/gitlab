# frozen_string_literal: true

FactoryBot.modify do
  factory :terraform_state_version, class: '::Terraform::StateVersion' do
    trait(:verification_succeeded) do
      with_file
      verification_checksum { 'abc' }
      verification_state { ::Terraform::StateVersion.verification_state_value(:verification_succeeded) }
    end

    trait(:verification_failed) do
      with_file
      verification_failure { 'Could not calculate the checksum' }
      verification_state { ::Terraform::StateVersion.verification_state_value(:verification_failed) }
    end
  end
end
