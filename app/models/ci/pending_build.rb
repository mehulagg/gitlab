# frozen_string_literal: true

module Ci
  class PendingBuild < ApplicationRecord
    extend Gitlab::Ci::Model

    belongs_to :project
    belongs_to :build, class_name: 'Ci::Build'

    scope :ref_protected, -> { where(protected: true) }
    scope :queued_before, ->(time) { where(arel_table[:created_at].lt(time)) }

    def self.upsert_from_build!(build)
      entry = self.new(args(build))

      entry.validate!

      self.upsert(entry.attributes.compact, returning: %w[build_id], unique_by: :build_id)
    end

    def self.args(build)
      {
        build: build,
        project: build.project,
        protected: build.protected?,
        shared_runner_enabled: runner_condition_satisfied?(build)
      }
    end

    def self.builds_access_level?(build)
      build.project.project_feature.builds_access_level.nil? || build.project.project_feature.builds_access_level > 0
    end

    def self.shared_runner_enabled?(build)
      !!build.project.shared_runners_enabled
    end

    def self.project_pending_delete?(build)
      !!build.project.pending_delete
    end

    def self.runner_condition_satisfied?(build)
      return false unless shared_runner_enabled?(build)
      return false unless builds_access_level?(build)
      return false unless project_pending_delete?(build)

      true
    end
  end
end
