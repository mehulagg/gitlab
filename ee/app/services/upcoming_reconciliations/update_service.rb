# frozen_string_literal: true

module UpcomingReconciliations
  class UpdateService
    def initialize(upcoming_reconciliations)
      @upcoming_reconciliations = upcoming_reconciliations
      @errors = []
    end

    def execute
      bulk_upsert

      result
    end

    private

    attr_reader :upcoming_reconciliations, :errors

    def bulk_upsert
      GitlabSubscriptions::UpcomingReconciliation.bulk_upsert!(parse_upsert_records, unique_by: 'namespace_id')
    rescue StandardError => e
      errors << { 'bulk_upsert' => e.message }
      Gitlab::AppLogger.error("Upcoming reconciliations bulk_upsert error: #{e.message}")
    end

    def parse_upsert_records
      upcoming_reconciliations.map do |attributes|
        parse_reconciliation(attributes)
      end.compact
    end

    def parse_reconciliation(attributes)
      attributes[:created_at] = attributes[:updated_at] = Time.zone.now
      reconciliation = GitlabSubscriptions::UpcomingReconciliation.new(attributes)

      if reconciliation.valid?
        reconciliation
      else
        errors << { reconciliation.namespace_id => reconciliation.errors.full_messages }
        nil
      end
    end

    def result
      errors.empty? ? ServiceResponse.success : ServiceResponse.error(message: errors.to_json)
    end
  end
end
