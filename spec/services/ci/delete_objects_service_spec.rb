# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Ci::DeleteObjectsService do
  let(:service) { described_class.new }
  let!(:artifact) { create(:ci_job_artifact, :archive) }

  before do
    Ci::DeletedObject.bulk_import([artifact])
  end

  describe '#execute' do
    subject { service.execute }

    it 'deletes records' do
      expect { subject }.to change { Ci::DeletedObject.count }.by(-1)
    end

    it 'deletes files' do
      expect { subject }.to change { artifact.file.exists? }
    end

    context 'when trying to remove the same file multiple times' do
      let(:objects) { Ci::DeletedObject.all }

      before do
        expect(service).to receive(:load_next_batch).twice.and_return(objects)
      end

      it 'executes successfully' do
        2.times { expect(service.execute).to be_truthy }
      end
    end
  end

  describe '#remaining_count' do
    subject { service.remaining_count(limit: 2) }

    it { is_expected.to eq(1) }
  end
end
