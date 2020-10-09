# frozen_string_literal: true

class Profiles::UsageQuotasController < Profiles::ApplicationController
  before_action do
    push_frontend_feature_flag(:additional_repo_storage_by_namespace, @group)
  end

  feature_category :purchase

  def index
    @namespace = current_user.namespace
    @projects = @namespace.projects.with_shared_runners_limit_enabled.page(params[:page])
  end
end
