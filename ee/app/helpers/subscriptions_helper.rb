# frozen_string_literal: true

module SubscriptionsHelper
  include ::Gitlab::Utils::StrongMemoize

  def subscription_data
    {
      setup_for_company: (current_user.setup_for_company == true).to_s,
      full_name: current_user.name,
      available_plans: subscription_available_plans.to_json,
      ci_minutes_plans: ci_minutes_plans.to_json,
      plan_id: params[:plan_id],
      namespace_id: params[:namespace_id],
      new_user: new_user?.to_s,
      group_data: group_data.to_json
    }
  end

  def plan_title
    strong_memoize(:plan_title) do
      plan = subscription_available_plans.find { |plan| plan[:id] == params[:plan_id] }
      plan[:code].titleize if plan
    end
  end

  private

  def new_user?
    return false unless request.referer.present?

    URI.parse(request.referer).path == users_sign_up_welcome_path
  end

  def plans_data
    GitlabSubscriptions::FetchSubscriptionPlansService.new(plan: :free).execute
      .map(&:symbolize_keys)
      .reject { |plan_data| plan_data[:free] }
      .map { |plan_data| plan_data.slice(:id, :code, :price_per_year, :deprecated, :name) }
  end

  def subscription_available_plans
    return plans_data unless ::Feature.enabled?(:hide_deprecated_billing_plans)

    plans_data.reject { |plan_data| plan_data[:deprecated] }
  end

  def ci_minutes_plans
    return if ::Feature.disabled?(:new_route_ci_minutes_purchase, default_enabled: :yaml)

    strong_memoize(:ci_minutes_plans) do
      fields = %w[
        name
        code
        active
        free
        price_per_month
        price_per_year
        features
        about_page_href
        hide_deprecated_card
      ]

      Gitlab::SubscriptionPortal::Client.plan_data("CI_1000_MINUTES_PLAN", fields)[:plans]
    end
  end

  def group_data
    current_user.manageable_groups_eligible_for_subscription.with_counts(archived: false).map do |namespace|
      {
        id: namespace.id,
        name: namespace.name,
        users: namespace.member_count,
        guests: namespace.guest_count
      }
    end
  end
end
