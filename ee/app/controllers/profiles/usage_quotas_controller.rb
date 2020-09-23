# frozen_string_literal: true

class Profiles::UsageQuotasController < Profiles::ApplicationController
  def index
    @namespace = current_user.namespace
    @projects = @namespace.projects.with_shared_runners_limit_enabled.page(params[:page])
  end
end
