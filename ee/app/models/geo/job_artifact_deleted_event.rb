# frozen_string_literal: true

module Geo
  class JobArtifactDeletedEvent < ApplicationRecord
    include Geo::Model
    include Geo::Eventable
    include BulkInsertSafe
    include IgnorableColumns

    ignore_column :job_artifact_id_convert_to_bigint, remove_with: '14.2', remove_after: '2021-08-22'

    belongs_to :job_artifact, class_name: 'Ci::JobArtifact'

    validates :job_artifact, :file_path, presence: true
  end
end
