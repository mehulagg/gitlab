# frozen_string_literal: true

module Ci
  class PendingBuild < ApplicationRecord
    extend Gitlab::Ci::Model

    belongs_to :project
    belongs_to :build, class_name: 'Ci::Build'

    def self.upsert_from_build!(build)
      entry = self.new(attributes(build))

      entry.validate!

      self.upsert(entry.attributes.compact, returning: %w[build_id], unique_by: :build_id)
    end

    def attributes(build)
      {
        build: build,
        project: build.project,
        protected: build.protected?,
        minutes_exceeded: minutes_exceeded?(build.project)
      }
    end

    def minutes_exceeded?(project)
      !!project.ci_minutes_quota.minutes_used_up?
    end
  end
end
