# frozen_string_literal: true

module Security
  module Ingestion
    # Updates the existing identifiers and creates the records for the new ones
    # in the database and returns a Hash object which maps the fingerprints with the DB IDs.
    class IngestIdentifiersService
      UNIQUE_BY = %i[project_id fingerprint].freeze

      def initialize(security_scan)
        @security_scan = security_scan
      end

      def execute
        upsert_identifiers.each_with_object({}).with_index do |(identifier_id, memo), index|
          fingerprint = all_identifiers[index].fingerprint

          memo[fingerprint] = identifier_id
        end
      end

      private

      attr_reader :security_scan

      delegate :project, :report_findings, to: :security_scan, private: true

      def upsert_identifiers
        Vulnerabilities::Identifier.upsert_all(upsert_data, unique_by: UNIQUE_BY).rows.flatten
      end

      def upsert_data
        all_identifiers.map do |identifier|
          identifier.to_hash.merge!(constant_attributes)
        end
      end

      def all_identifiers
        @all_identifiers ||= report_findings.flat_map { |finding| identifiers_of(finding) }.uniq
      end

      def identifiers_of(finding)
        finding.identifiers.take(Vulnerabilities::Finding::MAX_NUMBER_OF_IDENTIFIERS)
      end

      def constant_attributes
        @constant_attributes ||= { project_id: project.id, created_at: Time.zone.now, updated_at: Time.zone.now }
      end
    end
  end
end
