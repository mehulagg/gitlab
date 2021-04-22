# frozen_string_literal: true

require 'spec_helper'

RSpec.describe BulkImports::RelationExportWorker do
  let_it_be(:relation) { 'labels' }
  let_it_be(:user) { create(:user) }
  let_it_be(:group) { create(:group) }
  let_it_be_with_reload(:export) { create(:bulk_import_export, group: group) }

  let(:job_args) { [user.id, group.id, group.class.name, relation] }

  before do
    group.add_owner(user)
  end

  describe '#perform' do
    include_examples 'an idempotent worker' do
      context 'when export record does not exist' do
        let(:another_group) { create(:group) }
        let(:job_args) { [user.id, another_group.id, another_group.class.name, relation] }

        it 'creates export record' do
          another_group.add_owner(user)

          expect { perform_multiple(job_args) }
            .to change { another_group.bulk_import_exports.count }
            .from(0)
            .to(1)
        end
      end

      it 'executes RelationExportService' do
        service = instance_double(BulkImports::RelationExportService)

        expect(BulkImports::RelationExportService)
          .to receive(:new)
          .with(export)
          .twice
          .and_return(service)
        expect(service)
          .to receive(:execute)
          .twice

        perform_multiple(job_args)
      end

      it 'exports specified relation and marks export as finished' do
        perform_multiple(job_args)

        expect(export.upload.export_file).to be_present
        expect(export.finished?).to eq(true)
      end

      context 'when exception occurs during export' do
        shared_examples 'tracks exception' do |exception_class|
          it 'tracks exception' do
            expect(Gitlab::ErrorTracking)
              .to receive(:track_exception)
              .with(exception_class, exportable_id: group.id, exportable_type: group.class.name)
              .twice
              .and_call_original

            perform_multiple(job_args)
          end
        end

        before do
          allow_next_instance_of(BulkImports::ExportUpload) do |upload|
            allow(upload).to receive(:save!).and_raise(StandardError)
          end
        end

        it 'marks export as failed' do
          perform_multiple(job_args)

          expect(export.failed?).to eq(true)
        end

        include_examples 'tracks exception', StandardError

        context 'when passed relation is not supported' do
          let(:relation) { 'unsupported' }

          include_examples 'tracks exception', ActiveRecord::RecordInvalid
        end

        context 'when user is not allowed to perform export' do
          let(:another_user) { create(:user) }
          let(:job_args) { [another_user.id, group.id, group.class.name, relation] }

          include_examples 'tracks exception', Gitlab::ImportExport::Error
        end
      end
    end
  end
end
