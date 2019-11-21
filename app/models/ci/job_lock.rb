# frozen_string_literal: true

module Ci
  class JobLock < ApplicationRecord
    self.table_name = 'ci_job_locks'

    belongs_to :ci_semaphore, class_name: 'Ci::ProjectSemaphore', foreign_key: :semaphore_id, inverse_of: :job_locks
    belongs_to :job, class_name: 'Ci::Build', inverse_of: :job_lock

    delegate :under_limit?, to: :ci_semaphore

    state_machine :status, initial: :created do
      event :lock do
        transition created: :locking
      end

      event :block do
        transition created: :blocked
      end

      event :release do
        transition any - [:released] => :released
      end

      before_transition blocked: :locking do |job_lock|
        build.blocked_duration = Time.now - job_lock.updated_at
      end

      after_transition created: :locking do |job_lock|
        job_lock.job.enqueue
      end
    end

    enum status: {
      created: 0,
      locking: 1,
      blocked: 2,
      released: 3,
    }

    def try_lock
      under_limit? ? lock : block
    end
  end
end
