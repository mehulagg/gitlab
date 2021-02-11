# frozen_string_literal: true

class Admin::CloudLicensesController < Admin::ApplicationController
  respond_to :html

  feature_category :provision

  before_action :require_cloud_license_enabled

  def show
    if application_setting.cloud_license_auth_token.present?
      render
    else
      render :missing
    end
  end

  private

  def require_cloud_license_enabled
    redirect_to admin_license_path unless application_setting.cloud_license_enabled?
  end

  def application_setting
    Gitlab::CurrentSettings.current_application_settings
  end
end
