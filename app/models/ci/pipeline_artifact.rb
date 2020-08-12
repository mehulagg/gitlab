# frozen_string_literal: true

# This class is being used to persist additional artifacts after a pipeline completes, which is a great place to cache a computed result in object storage

module Ci
  class PipelineArtifact < ApplicationRecord
    extend Gitlab::Ci::Model
    include Artifactable

    FILE_STORE_SUPPORTED = [
      ObjectStorage::Store::LOCAL,
      ObjectStorage::Store::REMOTE
    ].freeze

    FILE_SIZE_LIMIT = 10.megabytes.freeze

    belongs_to :project, class_name: "Project", inverse_of: :pipeline_artifacts
    belongs_to :pipeline, class_name: "Ci::Pipeline", inverse_of: :pipeline_artifacts

    validates :pipeline, :project, :file_format, :file, presence: true
    validates :file_store, presence: true, inclusion: { in: FILE_STORE_SUPPORTED }
    validates :size, presence: true, numericality: { less_than_or_equal_to: FILE_SIZE_LIMIT }
    validates :file_type, presence: true, uniqueness: { scope: [:pipeline_id] }

    enum file_type: {
      code_coverage: 1
    }
  end
end
