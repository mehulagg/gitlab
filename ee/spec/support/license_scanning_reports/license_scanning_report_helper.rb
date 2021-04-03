# frozen_string_literal: true

module LicenseScanningReportHelper
  def create_report(dependencies)
    Gitlab::Ci::Reports::LicenseScanning::Report.new.tap do |report|
      dependencies.each do |license_name, dependencies|
        dependencies.each do |dependency_name|
          report
            .add_license(id: nil, name: license_name.to_s, url: "https://opensource.org/licenses/license1")
            .add_dependency(name: dependency_name)
        end
      end
    end
  end

  def create_report1
    create_report(
      License1: %w(Dependency1 Dependency2),
      License2: %w(Dependency1),
      License3: %w(Dependency3)
    )
  end

  def create_report2
    create_report(
      License2: %w(Dependency1),
      License3: %w(Dependency3),
      License4: %w(Dependency4 Dependency1)
    )
  end

  def create_comparer
    Gitlab::Ci::Reports::LicenseScanning::ReportsComparer.new(create_report1, create_report2)
  end

  def create_license
    Gitlab::Ci::Reports::LicenseScanning::License.new(id: nil, name: 'License1', url: "https://opensource.org/licenses/license1").tap do |license|
      license.add_dependency(name: 'Dependency1')
      license.add_dependency(name: 'Dependency2')
    end
  end

  def create_dependency
    Gitlab::Ci::Reports::LicenseScanning::Dependency.new(name: 'Dependency1')
  end
end
