# frozen_string_literal: true

class Profiles::UsageQuotasController < Profiles::ApplicationController
  before_action do
    push_additional_repo_storage_by_namespace_feature_flag
  end

  feature_category :purchase

  def index
    @namespace = current_user.namespace
    @projects = @namespace.projects.with_shared_runners_limit_enabled.page(params[:page])
  end

  def push_additional_repo_storage_by_namespace_feature_flag
    additional_repo_storage_by_namespace_flag = :additional_repo_storage_by_namespace
    gon.push({ features: { additional_repo_storage_by_namespace_flag.to_s.camelize(:lower) => @group.additional_repo_storage_by_namespace_enabled? } }, true)
  end
end
