# frozen_string_literal: true

FactoryBot.define do
  factory :in_product_marketing_email, class: 'Namespaces::InProductMarketingEmail' do
    namespace
    user

    track { 'create_track' }
    series { 0 }
  end
end
