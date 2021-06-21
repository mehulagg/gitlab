# frozen_string_literal: true

module Ci
  class PendingBuild < ApplicationRecord
    extend Gitlab::Ci::Model

    belongs_to :project
    belongs_to :build, class_name: 'Ci::Build'
    belongs_to :namespace, inverse_of: :ci_pending_builds, class_name: 'Namespace'

    scope :with_namespace, ->(namespace) { where(namespace: namespace) }

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
        minutes_exceeded: minutes_exceeded?(build.project),
        namespace_id: build.project.namespace.id # might need to preload this
      }
    end

    def self.minutes_exceeded?(project)
      !!project.ci_minutes_quota.minutes_used_up?
    end
  end
end
