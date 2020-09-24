# frozen_string_literal: true

module EE
  module MergeRequestPollCachedWidgetEntity
    extend ActiveSupport::Concern

    prepended do
      expose :merge_train_when_pipeline_succeeds_docs_path do |merge_request|
        presenter(merge_request).merge_train_when_pipeline_succeeds_docs_path
      end

      expose :policy_violation do |merge_request|
        presenter(merge_request).has_denied_policies?
      end

      # TODO: this is interesting; do we want to expose `enabled_reports` here
      # instead? Perhaps as enabled_security_scans?
      expose :missing_security_scan_types do |merge_request|
        presenter(merge_request).missing_security_scan_types
      end
    end
  end
end
