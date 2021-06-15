# frozen_string_literal: true

module Ci
  class PendingBuild < ApplicationRecord
    extend Gitlab::Ci::Model

    belongs_to :project
    belongs_to :build, class_name: 'Ci::Build'

    scope :ref_protected, -> { where(protected: true) }

    scope :matches_tag_ids, ->(tag_ids) do
      matcher = ::ActsAsTaggableOn::Tagging
        .where(taggable_type: CommitStatus.name)
        .where(context: 'tags')
        .where('taggable_id = ci_builds.id') # TODO !!!
        .where.not(tag_id: tag_ids).select('1')

      where("NOT EXISTS (?)", matcher)
    end

    scope :with_any_tags, -> do
      matcher = ::ActsAsTaggableOn::Tagging
        .where(taggable_type: CommitStatus.name)
        .where(context: 'tags')
        .where('taggable_id = ci_builds.id').select('1') # TODO !!!

      where("EXISTS (?)", matcher)
    end

    def self.upsert_from_build!(build)
      entry = self.new(build: build, project: build.project, protected: build.protected?)

      entry.validate!

      self.upsert(entry.attributes.compact, returning: %w[build_id], unique_by: :build_id)
    end
  end
end
