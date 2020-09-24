# frozen_string_literal: true

module EE
  module Gitlab
    module BackgroundMigration
      module MigrateApproverToApprovalRulesInBatch
        extend ::Gitlab::Utils::Override

        class MergeRequest < ActiveRecord::Base
          self.table_name = 'merge_requests'
        end

        override :perform
        def perform(start_id, end_id)
          merge_request_ids = MergeRequest.where('id >= ? AND id <= ?', start_id, end_id).pluck(:id)
          merge_request_ids.each do |merge_request_id|
            ::Gitlab::BackgroundMigration::MigrateApproverToApprovalRules.new.perform('MergeRequest', merge_request_id)
          end
        end
      end
    end
  end
end
