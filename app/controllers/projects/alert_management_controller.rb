# frozen_string_literal: true

class Projects::AlertManagementController < Projects::ApplicationController
  before_action :ensure_list_feature_enabled, only: :index
  before_action :ensure_detail_feature_enabled, only: :details

  def index
  end

  def details
    @alert_id = params[:id]
  end

  private

  def ensure_list_feature_enabled
    render_404 unless Feature.enabled?(:alert_management_minimal, project)
  end

  def ensure_detail_feature_enabled
    render_404 unless Feature.enabled?(:alert_management_detail, project)
  end
end
