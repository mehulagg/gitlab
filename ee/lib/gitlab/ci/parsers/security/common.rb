# frozen_string_literal: true

module Gitlab
  module Ci
    module Parsers
      module Security
        class Common
          SecurityReportParserError = Class.new(Gitlab::Ci::Parsers::ParserError)

          def parse!(json_data, report)
            report_data = parse_report(json_data)
            raise SecurityReportParserError, "Invalid report format" unless report_data.is_a?(Hash)

            create_scanner(report, report_data.dig('scan', 'scanner'))
            create_scan(report, report_data.dig('scan'))

            collate_remediations(report_data).each do |vulnerability|
              create_vulnerability(report, vulnerability, report_data["version"])
            end

            report_data
          rescue JSON::ParserError
            raise SecurityReportParserError, 'JSON parsing failed'
          rescue => e
            Gitlab::ErrorTracking.track_and_raise_for_dev_exception(e)
            raise SecurityReportParserError, "#{report.type} security report parsing failed"
          end

          protected

          def parse_report(json_data)
            Gitlab::Json.parse!(json_data)
          end

          # map remediations to relevant vulnerabilities
          def collate_remediations(report_data)
            return report_data["vulnerabilities"] || [] unless report_data["remediations"]

            fixes = fixes_from(report_data)
            report_data["vulnerabilities"].map do |vulnerability|
              remediation = fixes[vulnerability['id']] || fixes[vulnerability['cve']]
              vulnerability.merge("remediations" => [remediation])
            end
          end

          def fixes_from(report_data)
            report_data['remediations'].each_with_object({}) do |item, memo|
              item['fixes'].each do |fix|
                id = fix['id'] || fix['cve']
                memo[id] = item if id
              end
              memo
            end
          end

          def create_vulnerability(report, data, version)
            identifiers = create_identifiers(report, data['identifiers'])
            links = create_links(report, data['links'])
            report.add_finding(
              ::Gitlab::Ci::Reports::Security::Finding.new(
                uuid: SecureRandom.uuid,
                report_type: report.type,
                name: data['message'],
                compare_key: data['cve'] || '',
                location: create_location(data['location'] || {}),
                severity: parse_severity_level(data['severity']&.downcase),
                confidence: parse_confidence_level(data['confidence']&.downcase),
                scanner: create_scanner(report, data['scanner']),
                scan: report&.scan,
                identifiers: identifiers,
                links: links,
                raw_metadata: data.to_json,
                metadata_version: version))
          end

          def create_scan(report, scan_data)
            return unless scan_data.is_a?(Hash)

            report.scan = ::Gitlab::Ci::Reports::Security::Scan.new(scan_data)
          end

          def create_scanner(report, scanner)
            return unless scanner.is_a?(Hash)

            report.add_scanner(
              ::Gitlab::Ci::Reports::Security::Scanner.new(
                external_id: scanner['id'],
                name: scanner['name'],
                vendor: scanner.dig('vendor', 'name')))
          end

          def create_identifiers(report, identifiers)
            return [] unless identifiers.is_a?(Array)

            identifiers.map do |identifier|
              create_identifier(report, identifier)
            end.compact
          end

          def create_identifier(report, identifier)
            return unless identifier.is_a?(Hash)

            report.add_identifier(
              ::Gitlab::Ci::Reports::Security::Identifier.new(
                external_type: identifier['type'],
                external_id: identifier['value'],
                name: identifier['name'],
                url: identifier['url']))
          end

          def create_links(report, links)
            return [] unless links.is_a?(Array)

            links
              .map { |link| create_link(report, link) }
              .compact
          end

          def create_link(report, link)
            return unless link.is_a?(Hash)

            ::Gitlab::Ci::Reports::Security::Link.new(
              name: link['name'],
              url: link['url'])
          end

          def parse_severity_level(input)
            return input if ::Vulnerabilities::Finding::SEVERITY_LEVELS.key?(input)

            'unknown'
          end

          def parse_confidence_level(input)
            return input if ::Vulnerabilities::Finding::CONFIDENCE_LEVELS.key?(input)

            'unknown'
          end

          def create_location(location_data)
            raise NotImplementedError
          end
        end
      end
    end
  end
end
