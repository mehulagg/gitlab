# frozen_string_literal: true

module SubscriptionsHelper
  include ::Gitlab::Utils::StrongMemoize

  def subscription_data
    {
      setup_for_company: (current_user.setup_for_company == true).to_s,
      full_name: current_user.name,
      available_plans: subscription_available_plans.to_json,
      plan_id: params[:plan_id],
      namespace_id: params[:namespace_id],
      new_user: new_user?.to_s,
      group_data: group_data.to_json,
      available_addons: available_addons,
      is_addon_purchase: addon_purchase?.to_s
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
    FetchSubscriptionPlansService.new(plan: :free).execute
      .map(&:symbolize_keys)
      .reject { |plan_data| plan_data[:free] }
      .map { |plan_data| plan_data.slice(:id, :code, :price_per_year, :deprecated, :name, :addon) }
  end

  def subscription_available_plans
    return plans_data unless ::Feature.enabled?(:hide_deprecated_billing_plans)

    plans_data.reject { |plan_data| plan_data[:deprecated] || plan_data[:addon] }
  end

  def group_data
    current_user.manageable_groups_eligible_for_subscription.with_counts(archived: false).map do |namespace|
      {
        id: namespace.id,
        name: namespace.name,
        users: namespace.member_count
      }
    end
  end

  def available_addons
    plans_data.select { |plan_data| !plan_data[:deprecated] && plan_data[:addon] }
  end

  def addon_purchase?
    available_addons.any? { |plan_data| plan_data[:id] == params[:plan_id] }
  end
end
