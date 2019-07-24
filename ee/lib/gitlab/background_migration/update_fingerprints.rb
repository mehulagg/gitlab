# frozen_string_literal: true

module Gitlab
  module BackgroundMigration
    class UpdateFingerprints
      def update_all
        occurrences_to_update.each do |occurrence|
          metadata = JSON.parse(occurrence.raw_metadata)
          compare_key = metadata['cve']

          occurrence.update(project_fingerprint: Digest::SHA1.hexdigest(compare_key))
        end
      end

      private

      def occurrences_to_update
        ::Vulnerabilities::Occurrence.joins("#{left_join_feedback} #{on_fingerprints}")
      end

      def left_join_feedback
        'INNER JOIN vulnerability_feedback'
      end

      def on_fingerprints
        "ON #{occurrence_fingerprint} = #{feedback_fingerprint}"
      end

      def occurrence_fingerprint
        'CAST(vulnerability_occurrences.project_fingerprint AS varchar(42))'
      end

      def feedback_fingerprint
        "CONCAT('\\x', vulnerability_feedback.project_fingerprint)"
      end
    end
  end
end
