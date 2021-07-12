# frozen_string_literal: true

module Ci
  class ArchivePipelineService
    attr_reader :pipeline

    def initialize(pipeline)
      @pipeline = pipeline
    end

    # rubocop: disable CodeReuse/ActiveRecord
    def execute
      artifact = pipeline.pipeline_artifacts.create!(
        project_id: pipeline.project_id,
        file_type: :builds_metadata,
        file_format: :raw,
        size: carrierwave_file["tempfile"].size,
        file: carrierwave_file,
        expire_at: nil
      )

      pipeline.statuses.update_all(options: nil, yaml_variables: nil)
      Ci::BuildMetadata.where(build_id: pipeline.statuses).update_all(config_options: nil, config_variables: nil)

      artifact
    end
    # rubocop: enable CodeReuse/ActiveRecord

    private

    def carrierwave_file
      @carrierwave_file ||= CarrierWaveStringFile.new_file(
        file_content: builds_data.to_json,
        filename: Ci::PipelineArtifact::DEFAULT_FILE_NAMES.fetch(:builds_metadata),
        content_type: 'application/json'
      )
    end

    def builds_data
      pipeline.statuses.map do |status|
        {
          id: status.id,
          options: status.options,
          yaml_variables: status.yaml_variables
        }
      end
    end
  end
end
