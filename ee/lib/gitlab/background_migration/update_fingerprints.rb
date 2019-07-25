# frozen_string_literal: true

module Gitlab
  module BackgroundMigration
    class UpdateFingerprints
      def update_all
        update_occurrences
        update_feedback
      end

      private

      def update_feedback
        data_for_update.each do |feedback|
          metadata = JSON.parse(feedback['raw_metadata'])
          new_fingerprint = Digest::SHA1.hexdigest(metadata['cve'])

          ::Vulnerabilities::Occurrence.connection.execute(
            <<-UPDATE
              UPDATE vulnerability_feedback
              SET project_fingerprint = '#{new_fingerprint}'
              WHERE id = #{feedback['feedback_id']}
            UPDATE
          );
        end
      end

      def update_occurrences
        occurrences_to_update.each do |occurrence|
          metadata = JSON.parse(occurrence['raw_metadata'])
          new_fingerprint = Digest::SHA1.hexdigest(metadata['cve'])
          occurrence = ::Vulnerabilities::Occurrence.find(occurrence['occurrence_id'])

          occurrence.update(project_fingerprint: new_fingerprint)
        end
      end

      def occurrences_to_update
        data_for_update.uniq { |data| data['occurrence_id'] }
      end

      def data_for_update
        @data ||= ::Vulnerabilities::Occurrence.connection.select_all(
          <<-OCCURRENCES_QUERY
            SELECT
              vulnerability_occurrences.id AS occurrence_id,
              vulnerability_occurrences.raw_metadata,
              vulnerability_feedback.id AS feedback_id
            FROM vulnerability_occurrences
            INNER JOIN vulnerability_feedback
            ON #{occurrence_fingerprint} = #{feedback_fingerprint}
          OCCURRENCES_QUERY
        ).to_hash
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
