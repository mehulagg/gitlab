# frozen_string_literal: true

Gitlab::Seeder.quiet do
  Plan::PAID_HOSTED_PLANS.each do |plan|
    Plan.create!(name: plan, title: plan.titleize)

    print '.'
  end
end
