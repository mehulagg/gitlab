# frozen_string_literal: true

class Admin::SubscriptionsController < Admin::ApplicationController
  respond_to :html

  feature_category :license

  before_action :require_cloud_license_enabled

  def show; end

  private

  def require_cloud_license_enabled
    redirect_to admin_license_path unless cloud_license_enabled?
  end

  def cloud_license_enabled?
    Gitlab::CurrentSettings.cloud_license_enabled?
  end
end
