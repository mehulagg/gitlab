# frozen_string_literal: true

module Gitlab
  module Ci
    module Reports
      module LicenseManagement
        class Report
          attr_reader :found_licenses

          def initialize
            @found_licenses = {}
          end

          def licenses
            found_licenses.values.sort_by { |license| license.name.downcase }
          end

          def license_names
            found_licenses.values.map(&:name)
          end

          def add_dependency(license_name, license_count, license_url, dependency_name)
            key = license_name.upcase
            found_licenses[key] ||= ::Gitlab::Ci::Reports::LicenseManagement::License.new(license_name, license_count, license_url)
            found_licenses[key].add_dependency(dependency_name)
          end

          def violates?(software_license_policies)
            software_license_policies.blacklisted.with_license_by_name(license_names).exists?
          end
        end
      end
    end
  end
end
