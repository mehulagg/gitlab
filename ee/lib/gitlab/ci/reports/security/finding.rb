# frozen_string_literal: true

module Gitlab
  module Ci
    module Reports
      module Security
        class Finding
          include ::VulnerabilityFindingHelpers

          UNSAFE_SEVERITIES = %w[unknown high critical].freeze

          attr_reader :compare_key
          attr_reader :confidence
          attr_reader :identifiers
          attr_reader :links
          attr_reader :location
          attr_reader :metadata_version
          attr_reader :name
          attr_reader :old_location
          attr_reader :project_fingerprint
          attr_reader :raw_metadata
          attr_reader :report_type
          attr_reader :scanner
          attr_reader :scan
          attr_reader :severity
          attr_reader :uuid
          attr_reader :remediations
          attr_reader :details
          attr_reader :fingerprints
          attr_reader :project_id

          delegate :file_path, :start_line, :end_line, to: :location

          def initialize(compare_key:, identifiers:, links: [], remediations: [], location:, metadata_version:, name:, raw_metadata:, report_type:, scanner:, scan:, uuid:, confidence: nil, severity: nil, details: {}, fingerprints: [], project_id: nil, vulnerability_finding_fingerprints_enabled: false) # rubocop:disable Metrics/ParameterLists
            @compare_key = compare_key
            @confidence = confidence
            @identifiers = identifiers
            @links = links
            @location = location
            @metadata_version = metadata_version
            @name = name
            @raw_metadata = raw_metadata
            @report_type = report_type
            @scanner = scanner
            @scan = scan
            @severity = severity
            @uuid = uuid
            @remediations = remediations
            @details = details
            @fingerprints = fingerprints
            @project_id = project_id
            @vulnerability_finding_fingerprints_enabled = vulnerability_finding_fingerprints_enabled

            @project_fingerprint = generate_project_fingerprint
          end

          def to_hash
            %i[
              compare_key
              confidence
              identifiers
              links
              location
              metadata_version
              name
              project_fingerprint
              raw_metadata
              report_type
              scanner
              scan
              severity
              uuid
              details
              fingerprints
            ].each_with_object({}) do |key, hash|
              hash[key] = public_send(key) # rubocop:disable GitlabSecurity/PublicSend
            end
          end

          def primary_identifier
            identifiers.first
          end

          def update_location(new_location)
            @old_location = location
            @location = new_location
          end

          def unsafe?
            severity.in?(UNSAFE_SEVERITIES)
          end

          def eql?(other)
            return false unless report_type == other.report_type && primary_fingerprint == other.primary_fingerprint

            if @vulnerability_finding_fingerprints_enabled
              matches_fingerprints(other.fingerprints, other.uuid)
            else
              location.fingerprint == other.location.fingerprint
            end
          end

          def hash
            if @vulnerability_finding_fingerprints_enabled && !fingerprints.empty?
              highest_fingerprint = fingerprints.max_by(&:priority)
              report_type.hash ^ highest_fingerprint.fingerprint_hex.hash ^ primary_fingerprint.hash
            else
              report_type.hash ^ location.fingerprint.hash ^ primary_fingerprint.hash
            end
          end

          def valid?
            scanner.present? && primary_identifier.present? && location.present? && uuid.present?
          end

          def keys
            @keys ||= identifiers.reject(&:type_identifier?).map do |identifier|
              FindingKey.new(location_fingerprint: location&.fingerprint, identifier_fingerprint: identifier.fingerprint)
            end
          end

          def primary_fingerprint
            primary_identifier&.fingerprint
          end

          private

          def generate_project_fingerprint
            Digest::SHA1.hexdigest(compare_key)
          end
        end
      end
    end
  end
end
