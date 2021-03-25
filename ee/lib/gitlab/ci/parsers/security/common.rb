# frozen_string_literal: true

module Gitlab
  module Ci
    module Parsers
      module Security
        class Common
          SecurityReportParserError = Class.new(Gitlab::Ci::Parsers::ParserError)

          def self.parse!(json_data, report)
            new(json_data, report).parse!
          end

          def initialize(json_data, report)
            @json_data = json_data
            @report = report
          end

          def parse!
            raise SecurityReportParserError, "Invalid report format" unless report_data.is_a?(Hash)

            create_scanner
            create_scan
            collate_remediations.each { |vulnerability| create_vulnerability(vulnerability) }

            report_data
          rescue JSON::ParserError
            raise SecurityReportParserError, 'JSON parsing failed'
          rescue => e
            Gitlab::ErrorTracking.track_and_raise_for_dev_exception(e)
            raise SecurityReportParserError, "#{report.type} security report parsing failed"
          end

          private

          attr_reader :json_data, :report

          def report_data
            @report_data ||= Gitlab::Json.parse!(json_data)
          end

          def report_version
            @report_version ||= report_data['version']
          end

          def top_level_scanner
            @top_level_scanner ||= report_data.dig('scan', 'scanner')
          end

          def scan_data
            @scan_data ||= report_data.dig('scan')
          end

          # map remediations to relevant vulnerabilities
          def collate_remediations
            return report_data["vulnerabilities"] || [] unless report_data["remediations"]

            report_data["vulnerabilities"].map do |vulnerability|
              remediation = fixes[vulnerability['id']] || fixes[vulnerability['cve']]
              vulnerability.merge("remediations" => [remediation])
            end
          end

          def fixes
            @fixes ||= report_data['remediations'].each_with_object({}) do |item, memo|
              item['fixes'].each do |fix|
                id = fix['id'] || fix['cve']
                memo[id] = item if id
              end
              memo
            end
          end

          def tracking_data(data)
            data['tracking']
          end

          def create_vulnerability(data)
            identifiers = create_identifiers(data['identifiers'])
            links = create_links(data['links'])
            location = create_location(data['location'] || {})
            remediations = create_remediations(data['remediations'])
            fingerprints = create_fingerprints(location, tracking_data(data))

            vulnerability_finding_fingerprints_enabled = ::Feature.enabled?(:vulnerability_finding_fingerprints, report&.pipeline&.project)
            if vulnerability_finding_fingerprints_enabled && !fingerprints.empty?
              # NOT the fingerprint_sha256 - the compare key is hashed
              # to create the project_fingerprint
              highest_priority_fingerprint = fingerprints.max_by(&:priority)
              uuid = calculate_uuid_v5(identifiers.first, highest_priority_fingerprint.fingerprint_hex)
            else
              uuid = calculate_uuid_v5(identifiers.first, location&.fingerprint)
            end

            report.add_finding(
              ::Gitlab::Ci::Reports::Security::Finding.new(
                uuid: uuid,
                report_type: report.type,
                name: finding_name(data, identifiers, location),
                compare_key: data['cve'] || '',
                location: location,
                severity: parse_severity_level(data['severity']),
                confidence: parse_confidence_level(data['confidence']),
                scanner: create_scanner(data['scanner']),
                scan: report&.scan,
                identifiers: identifiers,
                links: links,
                remediations: remediations,
                raw_metadata: data.to_json,
                metadata_version: report_version,
                details: data['details'] || {},
                fingerprints: fingerprints,
                project_id: report.project_id,
                vulnerability_finding_fingerprints_enabled: vulnerability_finding_fingerprints_enabled))
          end

          def create_fingerprints(location, tracking)
            tracking ||= { 'items' => [] }

            fingerprint_algorithms = Hash.new { |hash, key| hash[key] = [] }

            tracking['items'].each do |item|
              next unless item.key?('fingerprints')

              item['fingerprints'].each do |fingerprint|
                alg = fingerprint['algorithm']
                fingerprint_algorithms[alg] << fingerprint['value']
              end
            end

            # We should *always* include the hash or physical-location-based
            # fingerprint!
            #
            # See the comments in VulnerabilityFindingFingerprintHelpers about
            # creating default fingerprints from location data
            is_location = [:file_path, :start_line].all? { |x| location.respond_to?(x) }
            algorithm_type = is_location ? 'location' : 'hash'
            unless fingerprint_algorithms.has_key?(algorithm_type)
              fingerprint_algorithms[algorithm_type] = [location.fingerprint_data]
            end

            fingerprint_algorithms.map do |algorithm, values|
              value = values.join('|')
              fingerprint = ::Gitlab::Ci::Reports::Security::FindingFingerprint.new(
                algorithm_type: algorithm,
                fingerprint_value: value
              )
              fingerprint.valid? ? fingerprint : nil
            end.compact
          end

          def create_scan
            return unless scan_data.is_a?(Hash)

            report.scan = ::Gitlab::Ci::Reports::Security::Scan.new(scan_data)
          end

          def create_scanner(scanner_data = top_level_scanner)
            return unless scanner_data.is_a?(Hash)

            report.add_scanner(
              ::Gitlab::Ci::Reports::Security::Scanner.new(
                external_id: scanner_data['id'],
                name: scanner_data['name'],
                vendor: scanner_data.dig('vendor', 'name')))
          end

          def create_identifiers(identifiers)
            return [] unless identifiers.is_a?(Array)

            identifiers.map { |identifier| create_identifier(identifier) }.compact
          end

          def create_identifier(identifier)
            return unless identifier.is_a?(Hash)

            report.add_identifier(
              ::Gitlab::Ci::Reports::Security::Identifier.new(
                external_type: identifier['type'],
                external_id: identifier['value'],
                name: identifier['name'],
                url: identifier['url']))
          end

          def create_links(links)
            return [] unless links.is_a?(Array)

            links.map { |link| create_link(link) }.compact
          end

          def create_link(link)
            return unless link.is_a?(Hash)

            ::Gitlab::Ci::Reports::Security::Link.new(name: link['name'], url: link['url'])
          end

          def create_remediations(remediations_data)
            remediations_data.to_a.compact.map do |remediation_data|
              ::Gitlab::Ci::Reports::Security::Remediation.new(remediation_data['summary'], remediation_data['diff'])
            end
          end

          def parse_severity_level(input)
            input&.downcase.then { |value| ::Enums::Vulnerability.severity_levels.key?(value) ? value : 'unknown' }
          end

          def parse_confidence_level(input)
            input&.downcase.then { |value| ::Enums::Vulnerability.confidence_levels.key?(value) ? value : 'unknown' }
          end

          def create_location(location_data)
            raise NotImplementedError
          end

          def create_tracking_location(tracking_data, fingerprint)
            Reports::Security::Locations::Tracking.new(tracking_data, fingerprint)
          end

          def finding_name(data, identifiers, location)
            return data['message'] if data['message'].present?
            return data['name'] if data['name'].present?

            identifier = identifiers.find(&:cve?) || identifiers.find(&:cwe?) || identifiers.first
            "#{identifier.name} in #{location&.fingerprint_path}"
          end

          def calculate_uuid_v5(primary_identifier, location_fingerprint)
            uuid_v5_name_components = {
              report_type: report.type,
              primary_identifier_fingerprint: primary_identifier&.fingerprint,
              location_fingerprint: location_fingerprint,
              project_id: report.project_id
            }

            if uuid_v5_name_components.values.any?(&:nil?)
              Gitlab::AppLogger.warn(message: "One or more UUID name components are nil", components: uuid_v5_name_components)
              return
            end

            ::Security::VulnerabilityUUID.generate(
              report_type: uuid_v5_name_components[:report_type],
              primary_identifier_fingerprint: uuid_v5_name_components[:primary_identifier_fingerprint],
              location_fingerprint: uuid_v5_name_components[:location_fingerprint],
              project_id: uuid_v5_name_components[:project_id]
            )
          end
        end
      end
    end
  end
end
