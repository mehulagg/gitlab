# frozen_string_literal: true
class Groups::Security::ComplianceDashboardsController < Groups::ApplicationController
  include Groups::SecurityFeaturesHelper
  include Analytics::UniqueVisitsHelper

  layout 'group'

  before_action :authorize_compliance_dashboard!
  before_action do
    push_frontend_feature_flag(:compliance_dashboard_drawer, @group, default_enabled: :yaml)
  end

  track_unique_visits :show, target_id: 'g_compliance_dashboard'

  feature_category :compliance_management

  def show
    @last_page = paginated_merge_requests.last_page?
    @merge_requests = serialize(paginated_merge_requests)
  end

  private

  def paginated_merge_requests
    @paginated_merge_requests ||= begin
      merge_requests = MergeRequestsComplianceFinder.new(current_user, { group_id: @group.id }).execute
      merge_requests.page(params[:page])
    end
  end

  def serialize(merge_requests)
    MergeRequestSerializer.new(current_user: current_user).represent(merge_requests, serializer: 'compliance_dashboard')
  end
end
