# frozen_string_literal: true

class Groups::SeatUsageController < Groups::ApplicationController
  before_action :authorize_admin_group!
  before_action :verify_namespace_plan_check_enabled

  before_action do
    push_frontend_feature_flag(:api_billable_member_list)
  end

  layout 'group_settings'

  feature_category :purchase

  def show; end
end
