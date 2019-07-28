# frozen_string_literal: true

module Gitlab
  module Vulnerabilities
    class UpdateFingerprints
      DastFormatter = ::Gitlab::Ci::Parsers::Security::Formatters::Dast
      ContainerScanningFormatter = ::Gitlab::Ci::Parsers::Security::Formatters::ContainerScanning

      def update_all
        find_occurrences.find_in_batches do |occurrences|
          feedback = find_feedback_batch(occurrences)
          fingerprinted_items = (occurrences + feedback).group_by(&:project_fingerprint)

          fingerprinted_items.each_value do |items|
            occurrence = items.find { |item| item.respond_to?(:raw_metadata) }
            metadata = JSON.parse(occurrence.raw_metadata)
            compare_key = compare_key(occurrence, metadata)
            new_fingerprint = Digest::SHA1.hexdigest(compare_key)

            items.each { |item| item.update(project_fingerprint: new_fingerprint) }
          end
        end
      end

      private

      def find_feedback_batch(occurrences)
        fingerprints = occurrences.map(&:project_fingerprint)

        ::Vulnerabilities::Feedback.where(project_fingerprint: fingerprints)
      end

      def find_occurrences
        ::Vulnerabilities::Occurrence.distinct
          .joins(joins_vulnerability_feedback)
      end

      def joins_vulnerability_feedback
        ActiveRecord::Base.sanitize_sql(
          "INNER JOIN vulnerability_feedback ON #{occurrence_fingerprint} = #{feedback_fingerprint}"
        )
      end

      def occurrence_fingerprint
        'CAST(vulnerability_occurrences.project_fingerprint AS varchar(42))'
      end

      def feedback_fingerprint
        "CONCAT('\\x', vulnerability_feedback.project_fingerprint)"
      end

      def compare_key(occurrence, metadata)
        if occurrence.dast?
          metadata = DastFormatter.new(metadata).format({ 'uri' => '' }, '')
        elsif occurrence.container_scanning?
          metadata = ContainerScanningFormatter.new(metadata).format('')
        end

        metadata['cve']
      end
    end
  end
end
