# frozen_string_literal: true

module Admin
  module LicenseRequest
    private

    def license
      @license ||= begin
        License.reset_current
        License.reset_future_dated
        License.reset_previous
        License.current
      end
    end

    def require_license
      return if license

      flash.keep
      redirect_to new_admin_license_path
    end

    def check_license_type
      if @license.cloud?
        flash[:error] = _('Cloud licenses can not be removed.')

        redirect_to admin_license_path
      end
    end
  end
end
