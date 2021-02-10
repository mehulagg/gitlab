# frozen_string_literal: true

class LicensesListEntity < ReportListEntity
  present_collection true, :licenses

  expose :licenses, using: LicenseEntity

  private

  def items_name
    :licenses
  end
end
