# frozen_string_literal: true

Gitlab::Seeder.quiet do
  # The default plan could already be created if Plan.default was called
  Plan.safe_find_or_create_by!(name: Plan::DEFAULT) { |plan| plan.title = Plan::DEFAULT.titleize }
  Plan.create!(name: Plan::FREE, title: Plan::FREE.titleize) if Gitlab.com?
end
