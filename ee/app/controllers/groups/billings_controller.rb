# frozen_string_literal: true

class Groups::BillingsController < Groups::ApplicationController
  before_action :authorize_admin_group!
  before_action :verify_namespace_plan_check_enabled

  before_action only: [:index] do
    push_frontend_feature_flag(:saas_manual_renew_button)
    push_frontend_feature_flag(:saas_add_seats_button)
  end

  layout 'group_settings'

  feature_category :purchase

  def index
    @top_most_group = @group.root_ancestor if @group.has_parent?
    relevant_group = (@top_most_group || @group)
    current_plan = relevant_group.plan_name_for_upgrading
    @plans_data = FetchSubscriptionPlansService.new(plan: current_plan, namespace_id: relevant_group.id).execute
    track_experiment_event(:contact_sales_btn_in_app, 'page_view:billing_plans:group')
    record_experiment_user(:contact_sales_btn_in_app)
  end
end
