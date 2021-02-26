# frozen_string_literal: true

module Gitlab
  module Ci
    module Parsers
      module Security
        class DependencyList
          def initialize(project, sha, pipeline)
            @formatter = Formatters::DependencyList.new(project, sha)
            @pipeline = pipeline
            @project = project
          end

          def parse!(json_data, report)
            report_data = Gitlab::Json.parse(json_data)
            parse_dependency_names(report_data, report)
            parse_vulnerabilities(report_data, report)
          end

          def parse_dependency_names(report_data, report)
            report_data.fetch('dependency_files', []).each do |file|
              file['dependencies'].each do |dependency|
                report.add_dependency(formatter.format(dependency, file['package_manager'], file['path']))
              end
            end
          end

          def parse_vulnerabilities(report_data, report)
            vuln_occurrences = pipeline.vulnerability_findings.dependency_scanning

            if Feature.enabled?(:standalone_vuln_dependency_list, project)
              vuln_occurrences.each do |occurrence|
                dependency = occurrence.location.dig("dependency")
                next unless dependency
                package_manager = "" # package manager will be extracted from the dependency_files
                file = occurrence.file
                vulnerability = occurrence.metadata
                report.add_dependency(formatter.format(dependency, package_manager, file, vulnerability))
              end
            else
              report_data.fetch('vulnerabilities', []).each do |vulnerability|
                dependency = vulnerability.dig("location", "dependency")
                file = vulnerability.dig("location", "file")
                report.add_dependency(formatter.format(dependency, '', file, vulnerability))
              end
            end
          end

          def parse_licenses!(json_data, report)
            license_report = ::Gitlab::Ci::Reports::LicenseScanning::Report.parse_from(json_data)
            license_report.licenses.each do |license|
              report.apply_license(license)
            end
          end

          private

          attr_reader :formatter, :pipeline, :project
        end
      end
    end
  end
end
