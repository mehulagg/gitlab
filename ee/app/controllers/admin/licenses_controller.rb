# frozen_string_literal: true

class Admin::LicensesController < Admin::ApplicationController
  include Admin::LicenseRequest

  before_action :license, only: [:show, :destroy]
  before_action :require_license, only: :destroy

  respond_to :html

  feature_category :license

  def show
    if @license.present? || License.future_dated_only?
      @licenses = License.history
    else
      render :missing
    end
  end

  def new
    build_license
  end

  def create
    return upload_license_error if license_params[:data].blank? && license_params[:data_file].blank?

    @license = License.new(license_params)

    return upload_license_error if @license.cloud?

    respond_with(@license, location: admin_license_path) do
      if @license.save
        notice = if @license.started?
                   _('The license was successfully uploaded and is now active. You can see the details below.')
                 else
                   _('The license was successfully uploaded and will be active from %{starts_at}. You can see the details below.' % { starts_at: @license.starts_at })
                 end

        flash[:notice] = notice
      end
    end
  end

  def destroy
    license.destroy

    if License.current
      flash[:notice] = _('The license was removed. GitLab has fallen back on the previous license.')
    else
      flash[:alert] = _('The license was removed. GitLab now no longer has a valid license.')
    end

    redirect_to admin_license_path, status: :found
  end

  def sync_seat_link
    sync_result = Gitlab::SeatLinkData.new.sync

    if sync_result
      flash[:notice] = _('Your license was successfully synced.')
    else
      flash[:error] = _('There was an error when trying to sync your license. Please verify that your instance is using an active license key.')
    end

    redirect_to admin_license_path
  end

  private

  def build_license
    @license ||= License.new(data: params[:trial_key])
  end

  def license_params
    license_params = params.require(:license).permit(:data_file, :data)
    license_params.delete(:data) if license_params[:data_file]
    license_params
  end

  def upload_license_error
    flash[:alert] = _('Please enter or upload a valid license.')
    @license = License.new
    redirect_to new_admin_license_path
  end
end
