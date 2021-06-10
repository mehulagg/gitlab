# frozen_string_literal: true

class Profiles::BillingsController < Profiles::ApplicationController
  before_action :verify_namespace_plan_check_enabled

  feature_category :purchase

  def index
    @hide_search_settings = true
    @plans_data = GitlabSubscriptions::FetchSubscriptionPlansService
      .new(plan: current_user.namespace.plan_name_for_upgrading, namespace_id: current_user.namespace_id)
      .execute

    if @plans_data
      track_experiment_event(:contact_sales_btn_in_app, 'page_view:billing_plans:profile')
      record_experiment_user(:contact_sales_btn_in_app)
    else
      render 'shared/billings/customers_dot_unavailable'
    end
  end
end
