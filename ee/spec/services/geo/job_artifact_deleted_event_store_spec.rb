# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Geo::JobArtifactDeletedEventStore do
  include EE::GeoHelpers

  let_it_be(:secondary_node) { create(:geo_node) }
  let_it_be(:job_artifact) { create(:ci_job_artifact, :archive) }
  let_it_be(:invalid_job_artifact) { create(:ci_job_artifact) }
  let_it_be(:project) { invalid_job_artifact.project }
  let_it_be(:expected_error_message) do
    {
      class: "Geo::JobArtifactDeletedEventStore",
      host: "localhost",
      job_artifact_id: invalid_job_artifact.id,
      project_id: project.id,
      project_path: project.full_path,
      storage_version: project.storage_version,
      message: "Job artifact deleted event could not be created",
      error: "Validation failed: File path can't be blank"
    }
  end

  describe '#create!' do
    subject { described_class.new(job_artifact) }

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
        subject = described_class.new(invalid_job_artifact)

        expect(Gitlab::Geo::Logger).to receive(:error)
          .with(expected_error_message).and_call_original

        subject.create!
      end
    end
  end

  describe '.bulk_create' do
    subject(:bulk_create) { described_class.bulk_create([job_artifact]) }

    context 'when running on a secondary node' do
      before do
        stub_secondary_node
      end

      it 'does not create an event' do
        expect { bulk_create }.not_to change(Geo::JobArtifactDeletedEvent, :count)
      end
    end

    context 'when running on a primary node' do
      before do
        stub_primary_node
      end

      it 'does not create an event if there are no secondary nodes' do
        allow(Gitlab::Geo).to receive(:secondary_nodes) { [] }

        expect { bulk_create }.not_to change(Geo::JobArtifactDeletedEvent, :count)
      end

      it 'creates an event' do
        expect { bulk_create }.to change(Geo::JobArtifactDeletedEvent, :count).by(1)
      end

      context 'when file subject is not on local store' do
        before do
          allow(job_artifact).to receive(:local?).and_return(false)
        end

        it 'creates an event' do
          expect { bulk_create }.to change(Geo::JobArtifactDeletedEvent, :count).by(1)
        end
      end

      it 'tracks artifact attributes' do
        bulk_create

        event = Geo::JobArtifactDeletedEvent.last

        expect(event).to have_attributes(
          job_artifact_id: job_artifact.id,
          file_path: match(%r{\A\h+/\h+/\h+/[\d_]+/\d+/\d+/ci_build_artifacts.zip\z})
        )

        expect(event.geo_event_log).to be_present
      end

      it 'logs an error message when event creation fail' do
        expect(Gitlab::Geo::Logger).to receive(:error)
          .with(expected_error_message).and_call_original

        described_class.bulk_create([invalid_job_artifact])
      end

      it 'inserts valid artifacts and logs errors for invalid ones' do
        expect(Gitlab::Geo::Logger).to receive(:error)
          .with(expected_error_message).and_call_original

        expect { described_class.bulk_create([invalid_job_artifact, job_artifact]) }
          .to change { Geo::JobArtifactDeletedEvent.count }.by(1)

        expect(Geo::JobArtifactDeletedEvent.last).to have_attributes(
          job_artifact_id: job_artifact.id,
          file_path: match(%r{\A\h+/\h+/\h+/[\d_]+/\d+/\d+/ci_build_artifacts.zip\z})
        )
      end
    end
  end
end
