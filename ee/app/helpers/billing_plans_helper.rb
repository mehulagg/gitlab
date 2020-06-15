# frozen_string_literal: true

module BillingPlansHelper
  def subscription_plan_info(plans_data, current_plan_code)
    plans_data.find { |plan| plan.code == current_plan_code }
  end

  def number_to_plan_currency(value)
    number_to_currency(value, unit: '$', strip_insignificant_zeros: true, format: "%u%n")
  end

  def current_plan?(plan)
    plan.purchase_link&.action == 'current_plan'
  end

  def plan_purchase_link(href, link_text)
    if href
      link_to link_text, href, class: 'btn gl-button-deprecated btn-success'
    else
      button_tag link_text, class: 'btn gl-button-deprecated disabled'
    end
  end

  def new_gitlab_com_trial_url
    "#{EE::SUBSCRIPTIONS_URL}/trials/new?gl_com=true"
  end

  def subscription_plan_data_attributes(group, plan)
    return {} unless group

    {
      namespace_id: group.id,
      namespace_name: group.name,
      plan_upgrade_href: plan_upgrade_url(group, plan),
      customer_portal_url: "#{EE::SUBSCRIPTIONS_URL}/subscriptions"
    }
  end

  def plan_upgrade_url(group, plan)
    return unless group && plan&.id

    "#{EE::SUBSCRIPTIONS_URL}/gitlab/namespaces/#{group.id}/upgrade/#{plan.id}"
  end

  def use_new_purchase_flow?(namespace)
    namespace.group? &&
      namespace.actual_plan_name == Plan::FREE &&
      Feature.enabled?(:free_group_new_purchase_flow, current_user)
  end

  def plan_purchase_url(group, plan)
    if use_new_purchase_flow?(group)
      new_subscriptions_path(plan_id: plan.id, namespace_id: group.id)
    else
      "#{plan.purchase_link.href}&gl_namespace_id=#{group.id}"
    end
  end

  def plan_feature_short_list(plan)
    return [] unless plan.features

    plan.features.sort_by! { |feature| feature.highlight ? 0 : 1 }[0...4]
  end

  def plan_purchase_or_upgrade_url(group, plan, current_plan)
    if group.upgradable?
      plan_upgrade_url(group, current_plan)
    else
      plan_purchase_url(group, plan)
    end
  end

  def show_plans?(namespace)
    namespace.trial_active? || !namespace.gold_plan?
  end

  def show_trial_banner?(namespace)
    return false unless params[:trial]

    root = namespace.has_parent? ? namespace.root_ancestor : namespace
    root.trial_active?
  end

  def namespace_for_user?(namespace)
    namespace == current_user.namespace
  end
end
