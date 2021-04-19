# frozen_string_literal: true

module Ci
  class UpdateApprovalRulesService < ::BaseService
    def initialize(pipeline)
      @pipeline = pipeline
    end

    def execute
      update_coverage_rules
      success
    rescue StandardError => error
      log_error(
        pipeline: pipeline&.to_param,
        error: error.class.name,
        message: error.message,
        source: "#{__FILE__}:#{__LINE__}",
        backtrace: error.backtrace
      )
      error("Failed to update approval rules")
    end

    private

    attr_reader :pipeline

    def update_coverage_rules
      # If we have some reports, then we want to sync them early;
      # If we don't have reports, then we should wait until pipeline stops.
      return if reports.files.empty? && !pipeline.complete?

      remove_required_approvals_for(ApprovalMergeRequestRule.coverage_report, sync_required_merge_requests)
    end

    def reports
      @reports ||= pipeline.coverage_reports
    end

    def sync_required_merge_requests
      pipeline.merge_requests_as_head_pipeline.select do |merge_request|
        # check against base pipeline here
        # merge_request.base_pipeline&.coverage_reports
        reports.violates_against?(merge_request.new_paths)
      end
    end

    def remove_required_approvals_for(rules, merge_requests)
      rules.for_unmerged_merge_requests(merge_requests).update_all(approvals_required: 0)
    end
  end
end
