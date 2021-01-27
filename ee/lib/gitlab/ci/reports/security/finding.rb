# frozen_string_literal: true

module Gitlab
  module Ci
    module Reports
      module Security
        class Finding
          UNSAFE_SEVERITIES = %w[unknown high critical].freeze

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

          attr_reader :trackings

          delegate :file_path, :start_line, :end_line, to: :location

          def initialize(identifiers:, links: [], remediations: [], location:, metadata_version:, name:, raw_metadata:, report_type:, scanner:, scan:, uuid:, trackings:, confidence: nil, severity: nil, details: {}) # rubocop:disable Metrics/ParameterLists
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
            @trackings = trackings || []
            @remediations = remediations
            @details = details

            @project_fingerprint = generate_project_fingerprint
          end

          def to_hash
            %i[
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
              trackings
              details
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
            report_type == other.report_type &&
              matches_fingerprints(other) &&
              primary_fingerprint == other.primary_fingerprint
          end
          alias_method :==, :eql?

          def highest_priority_tracking
            trackings.max_by(&:priority)
          end

          def matches_fingerprints(other)
            # ascending priority
            other_tfs = other.trackings.sort_by(&:priority)
            res = false

            # descending priority
            trackings.sort_by(&:priority).reverse_each do |tf|
              next_highest_other_tf = other_tfs.pop
              while !next_highest_other_tf.nil? && next_highest_other_tf.same_type?(tf)
                if tf == next_highest_other_tf
                  res = true
                  break
                end

                next_highest_other_tf = other_tfs.pop
              end

              break if res
            end
            res
          end

          def hash
            report_type.hash ^ location.fingerprint.hash ^ primary_fingerprint.hash
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

          alias_method :first_fingerprint, :primary_fingerprint

          private

          def generate_project_fingerprint
            @location.fingerprint
          end
        end
      end
    end
  end
end
