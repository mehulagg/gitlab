# frozen_string_literal: true

module Gitlab
  module Ci
    module Reports
      module Security
        class Finding
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
          attr_reader :signatures
          attr_reader :project_id

          delegate :file_path, :start_line, :end_line, to: :location

          def initialize(compare_key:, identifiers:, links: [], remediations: [], location:, metadata_version:, name:, raw_metadata:, report_type:, scanner:, scan:, uuid:, confidence: nil, severity: nil, details: {}, signatures: [], project_id: nil) # rubocop:disable Metrics/ParameterLists
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
            @signatures = signatures
            @project_id = project_id

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

            if ::Feature.enabled?(:vulnerability_finding_fingerprints)
              matches_fingerprints(other.fingerprints, other.uuid)
            else
              location.fingerprint == other.location.fingerprint
            end
          end

          def hash
            if Feature.enabled?(:vulnerability_finding_fingerprints) && !fingerints.empty?
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

          # this should match the same code as in ee/app/models/vulnerabilities/finding.rb
          def matches_fingerprints(other_fingerprints, other_uuid)
            other_fingerprint_types = other_fingerprints.index_by(&:algorithm_type)

            # highest first
            match_result = nil
            fingerprints.sort_by(&:priority).reverse_each do |fingerprint|
              matching_other_fingerprint = other_fingerprint_types[fingerprint.algorithm_type]
              next if matching_other_fingerprint.nil?

              match_result = matching_other_fingerprint == fingerprint
              break
            end

            if match_result.nil?
              Set.new([uuid, *fingerprint_uuids]).include?(other_uuid)
            else
              match_result
            end
          end

          def fingerprint_uuids
            fingerprints.map do |fingerprint|
              hex_sha = fingerprint.fingerprint_hex
              Gitlab::UUID.v5(uuid_v5_name(location_fingerprint_value: hex_sha))
            end
          end

          private

          def generate_project_fingerprint
            Digest::SHA1.hexdigest(compare_key)
          end

          def uuid_v5_name(location_fingerprint_value: nil)
            [
              report_type,
              primary_identifier.fingerprint,
              location_fingerprint_value || location.fingerprint,
              project_id
            ].join('-')
          end
        end
      end
    end
  end
end
