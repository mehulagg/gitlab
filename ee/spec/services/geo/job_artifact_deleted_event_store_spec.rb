# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Geo::JobArtifactDeletedEventStore do
  include EE::GeoHelpers

  let_it_be(:secondary_node) { create(:geo_node) }

  let(:job_artifact) { create(:ci_job_artifact, :archive) }

  subject { described_class.new(job_artifact) }

  describe '#create!' do
    it_behaves_like 'a Geo event store', Geo::JobArtifactDeletedEvent do
      let(:file_subject) { job_artifact }
    end

    context 'when running on a primary node' do
      before do
        stub_primary_node
      end

      it 'tracks artifact attributes' do
        subject.create!

        expect(Geo::JobArtifactDeletedEvent.last).to have_attributes(
          job_artifact_id: job_artifact.id,
          file_path: match(%r{\A\h+/\h+/\h+/[\d_]+/\d+/\d+/ci_build_artifacts.zip\z})
        )
      end

      it 'logs an error message when event creation fail' do
        invalid_job_artifact = create(:ci_job_artifact)
        project = invalid_job_artifact.project
        subject = described_class.new(invalid_job_artifact)

        expected_message = {
          class: "Geo::JobArtifactDeletedEventStore",
          host: "localhost",
          job_artifact_id: invalid_job_artifact.id,
          project_id: project.id,
          project_path: project.full_path,
          storage_version: project.storage_version,
          message: "Job artifact deleted event could not be created",
          error: "Validation failed: File path can't be blank"
        }

        expect(Gitlab::Geo::Logger).to receive(:error)
          .with(expected_message).and_call_original

        subject.create!
      end
    end
  end
end
