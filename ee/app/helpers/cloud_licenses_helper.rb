# frozen_string_literal: true

module CloudLicensesHelper
  def cloud_licenses_view_data
    {
      current_plan_title: current_license_title
    }
  end

  private

  def current_license_title
    License.current&.plan&.titleize || 'Core'
  end
end
