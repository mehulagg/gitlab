# frozen_string_literal: true

class Groups::UsageQuotasController < Groups::ApplicationController
  before_action :authorize_admin_group!
  before_action :verify_usage_quotas_enabled!
  before_action do
    push_additional_repo_storage_by_namespace_feature_flag
  end

  layout 'group_settings'

  feature_category :purchase

  def index
    @projects = @group.all_projects.with_shared_runners_limit_enabled.page(params[:page])
  end

  private

  def verify_usage_quotas_enabled!
    render_404 unless License.feature_available?(:usage_quotas)
    render_404 if @group.has_parent?
  end

  def push_additional_repo_storage_by_namespace_feature_flag
    additional_repo_storage_by_namespace_flag = :additional_repo_storage_by_namespace
    gon.push({ features: { additional_repo_storage_by_namespace_flag.to_s.camelize(:lower) => @group.additional_repo_storage_by_namespace_enabled? } }, true)
  end
end
