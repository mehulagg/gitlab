# frozen_string_literal: true

class DependencyListEntity < ReportListEntity
  present_collection true, :dependencies

  expose :dependencies, using: DependencyEntity

  private

  def items_name
    :dependencies
  end
end
