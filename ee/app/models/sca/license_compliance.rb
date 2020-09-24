# frozen_string_literal: true

module SCA
  class LicenseCompliance
    include ::Gitlab::Utils::StrongMemoize

    SORT_DIRECTION = {
      asc: -> (items) { items },
      desc: -> (items) { items.reverse }
    }.with_indifferent_access

    def initialize(project, pipeline)
      @project = project
      @pipeline = pipeline
    end

    def policies
      strong_memoize(:policies) do
        unclassified_policies.merge(known_policies).sort.map(&:last)
      end
    end

    def find_policies(detected_only: false, classification: [], sort: { by: :name, direction: :asc })
      classifications = Array(classification || [])
      matching_policies = policies.reject do |policy|
        (detected_only && policy.dependencies.none?) ||
          (classifications.present? && !policy.classification.in?(classifications))
      end
      sort_items(items: matching_policies, by: sort&.dig(:by), direction: sort&.dig(:direction))
    end

    def latest_build_for_default_branch
      return if pipeline.blank?

      strong_memoize(:latest_build_for_default_branch) do
        pipeline.builds.latest.license_scan.last
      end
    end

    def report_for(policy)
      build_policy(license_scan_report[policy.software_license.canonical_id], policy)
    end

    private

    attr_reader :project, :pipeline

    def known_policies
      strong_memoize(:known_policies) do
        project.software_license_policies.including_license.unreachable_limit.map do |policy|
          [policy.software_license.canonical_id, report_for(policy)]
        end.to_h
      end
    end

    def unclassified_policies
      license_scan_report.licenses.map do |reported_license|
        next if known_policies[reported_license.canonical_id]

        [reported_license.canonical_id, build_policy(reported_license, nil)]
      end.compact.to_h
    end

    def license_scan_report
      return empty_report if pipeline.blank?

      strong_memoize(:license_scan_report) do
        pipeline.license_scanning_report.tap do |report|
          report.apply_details_from!(dependency_list_report)
        end
      rescue ::Gitlab::Ci::Parsers::LicenseCompliance::LicenseScanning::LicenseScanningParserError
        empty_report
      end
    end

    def dependency_list_report
      pipeline.dependency_list_report
    rescue ::Gitlab::Ci::Parsers::LicenseCompliance::LicenseScanning::LicenseScanningParserError
    end

    def empty_report
      ::Gitlab::Ci::Reports::LicenseScanning::Report.new
    end

    def build_policy(reported_license, software_license_policy)
      ::SCA::LicensePolicy.new(reported_license, software_license_policy)
    end

    def sort_items(items:, by:, direction:, available_attributes: ::SCA::LicensePolicy::ATTRIBUTES)
      attribute = available_attributes[by] || available_attributes[:name]
      direction = SORT_DIRECTION[direction] || SORT_DIRECTION[:asc]
      direction.call(items.sort_by { |item| attribute.call(item) })
    end
  end
end
