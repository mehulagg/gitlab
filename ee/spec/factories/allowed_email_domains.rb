# frozen_string_literal: true

FactoryBot.define do
  factory :allowed_email_domain, class: 'AllowedEmailDomain' do
    domain { 'gitlab.com' }
    group
  end
end
