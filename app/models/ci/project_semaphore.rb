# frozen_string_literal: true

module Ci
  class ProjectSemaphore < ApplicationRecord
    self.table_name = 'ci_project_semaphores'

    belongs_to :project, inverse_of: :ci_semaphores

    has_many :job_locks, class_name: 'Ci::JobLock', foreign_key: :semaphore_id

    validates :key, length: { minimum: 1, maximum: 255 }

    def under_limit?
      job_locks.locking.count < concurrency
    end

    def unlock_next(from:)
      next_blocked(from.id)&.obtain
    end

    def next_blocked(from_id)
      job_locks.blocked.where('id > ?', from_id).order(:id).take
    end
  end
end
