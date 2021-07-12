# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Ci::ArchivePipelineService do
  let_it_be(:pipeline) { create(:ci_pipeline, :with_job) }

  let(:service) { described_class.new(pipeline) }

  describe '#execute' do
    it 'creates a metadata artifact' do
      expect { service.execute }
        .to change { Ci::PipelineArtifact.count }
        .by(1)
    end

    it 'saves build attributes' do
      artifact = service.execute
      job = pipeline.builds.first
      expected_data = [
        {
          id: job.id,
          options: job.options,
          yaml_variables: job.yaml_variables
        }.deep_stringify_keys
      ]

      expect(Gitlab::Json.parse(artifact.file.read)).to match_array(expected_data)
    end
  end
end
