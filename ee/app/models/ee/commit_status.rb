# frozen_string_literal: true
module EE
  module CommitStatus
    extend ActiveSupport::Concern

    EE_FAILURE_REASONS = {
      protected_environment_failure: 1_000
    }.freeze

    prepended do
      state_machine :status do

        event :enqueue do
          transition [:created, :waiting_for_resource, :preparing, :manual, :scheduled] => :failed, unless: :ci_quota_available?
        end

        before_transition on: :enqueue, any => :failed do |commit_status, transition|
          commit_status.failure_reason = CommitStatus.failure_reasons[:ci_quota_exceeded]
        end
      end
    end

    def ci_quota_available?
      true
    end

    def all_met_to_become_pending?
      super && ci_quota_available?
    end
  end
end
