# frozen_string_literal: true

module EE
  module Gitlab
    module BackgroundMigration
      module MigrateApproverToApprovalRulesCheckProgress
        extend ::Gitlab::Utils::Override

        RESCHEDULE_DELAY = 1.day

        override :perform
        def perform
          if remaining?
            ::BackgroundMigrationWorker.perform_in(RESCHEDULE_DELAY, self.class.name)
          end
        end

        private

        def remaining?
          ::Gitlab::BackgroundMigration.exists?('MigrateApproverToApprovalRulesInBatch')
        end
      end
    end
  end
end
