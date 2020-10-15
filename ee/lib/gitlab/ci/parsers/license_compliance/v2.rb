# frozen_string_literal: true

module Gitlab
  module Ci
    module Parsers
      module LicenseCompliance
        class V2
          attr_reader :report

          def initialize(report)
            @report = report
          end

          def parse(report_hash)
            add_licenses(report_hash)
            add_dependencies(report_hash)
          end

          private

          def add_licenses(report_hash)
            report_hash[:licenses].map do |license_hash|
              report.add_license(id: license_hash[:id], name: license_hash[:name], url: license_hash[:url])
            end
          end

          def add_dependencies(report_hash)
            report_hash[:dependencies].each do |dependency_hash|
              dependency_hash[:licenses].map do |license_id|
                license_for(license_id).add_dependency(dependency_hash)
              end
            end
          end

          def license_for(license_id)
            report.fetch(license_id) do |_key|
              report.add_license(id: license_id, name: 'unknown')
            end
          end
        end
      end
    end
  end
end
