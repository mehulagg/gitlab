# frozen_string_literal: true

module Ci
  class SharedRunnerBuild < ApplicationRecord
    extend Gitlab::Ci::Model

    belongs_to :project
    belongs_to :build, class_name: 'Ci::Build'
    belongs_to :runner, class_name: 'Ci::Runner'

    def self.upsert_from_build!(build)
      unless build.runner && build.runner.instance_type?
        raise ArgumentError, 'build has not been picked by a shared runner'
      end

      entry = self.new(build: build, project: build.project, runner: build.runner)

      entry.validate!

      self.upsert(entry.attributes.compact, returning: %w[build_id], unique_by: :build_id)
    end
  end
end
