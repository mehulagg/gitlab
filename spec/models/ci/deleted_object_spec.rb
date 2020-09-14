# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Ci::DeletedObject do
  describe 'attributes' do
    it { is_expected.to respond_to(:file) }
    it { is_expected.to respond_to(:store_dir) }
    it { is_expected.to respond_to(:file_store) }
    it { is_expected.to respond_to(:pick_up_at) }
  end

  describe '.bulk_import' do
    context 'with data' do
      let!(:artifact) { create(:ci_job_artifact, :archive, :expired) }

      it 'imports data', :aggregate_failures do
        expect { described_class.bulk_import(Ci::JobArtifact.all) }.to change { described_class.count }.by(1)

        deleted_artifact = described_class.first

        expect(deleted_artifact.file_store).to eq(artifact.file_store)
        expect(deleted_artifact.store_dir).to eq(artifact.file.store_dir.to_s)
        expect(deleted_artifact.file_identifier).to eq(artifact.file_identifier)
        expect(deleted_artifact.pick_up_at).to eq(artifact.expire_at)
      end
    end

    context 'with invalid data', :aggregate_failures do
      let!(:artifact) { create(:ci_job_artifact) }

      it 'does not import anything' do
        expect(artifact.file_identifier).to be_nil

        expect { described_class.bulk_import([artifact]) }
          .not_to change { described_class.count }
      end
    end

    context 'with empty data' do
      it 'returns successfully' do
        expect { described_class.bulk_import([]) }
          .not_to change { described_class.count }
      end
    end
  end

  context 'ActiveRecord scopes' do
    let_it_be(:not_ready) { create(:ci_deleted_object, pick_up_at: 1.day.from_now) }
    let_it_be(:ready) { create(:ci_deleted_object, pick_up_at: 1.day.ago) }

    describe '.lock_for_destruction' do
      it 'returns objects that are ready' do
        result = described_class.lock_for_destruction(2)

        expect(result).to contain_exactly(ready)
        expect(result.locked?).to eq('FOR UPDATE SKIP LOCKED')
      end
    end

    describe '.for_relationship' do
      it 'returns a relationship containing requested objects' do
        relationship = described_class.id_in(ready.id).load
        result = described_class.for_relationship(relationship)

        expect(result).to contain_exactly(ready)
      end
    end
  end
end
