# frozen_string_literal: true

require 'spec_helper'

describe Groups::ImportExport::ImportService do
  describe '#async_execute' do
    let_it_be(:user) { create(:user) }
    let_it_be(:group) { create(:group) }

    context 'when the job can be successfully scheduled' do
      subject(:import_service) { described_class.new(group: group, user: user) }

      it 'enqueues an import job' do
        expect(GroupImportWorker).to receive(:perform_async).with(user.id, group.id)

        import_service.async_execute
      end

      it 'returns truthy' do
        expect(import_service.async_execute).to be_truthy
      end
    end

    context 'when the job cannot be scheduled' do
      subject(:import_service) { described_class.new(group: group, user: user) }

      before do
        allow(GroupImportWorker).to receive(:perform_async).and_return(nil)
      end

      it 'returns falsey' do
        expect(import_service.async_execute).to be_falsey
      end
    end
  end

  context 'with group_import_ndjson feature flag disabled' do
    let(:user) { create(:admin) }
    let(:group) { create(:group) }
    let(:import_logger) { instance_double(Gitlab::Import::Logger) }

    subject(:service) { described_class.new(group: group, user: user) }

    before do
      stub_feature_flags(group_import_ndjson: false)

      ImportExportUpload.create(group: group, import_file: import_file)

      allow(Gitlab::Import::Logger).to receive(:build).and_return(import_logger)
      allow(import_logger).to receive(:error)
      allow(import_logger).to receive(:info)
    end

    context 'with a json file' do
      let(:import_file) { fixture_file_upload('spec/fixtures/legacy_group_export.tar.gz') }

      it 'uses LegacyTreeRestorer to import the file' do
        expect(Gitlab::ImportExport::Group::LegacyTreeRestorer).to receive(:new).and_call_original

        service.execute
      end
    end

    context 'with a ndjson file' do
      let(:import_file) { fixture_file_upload('spec/fixtures/group_export.tar.gz') }

      it 'fails to import' do
        expect { service.execute }.to raise_error(Gitlab::ImportExport::Error, 'Incorrect JSON format')
      end
    end
  end

  context 'with group_import_ndjson feature flag enabled' do
    before do
      stub_feature_flags(group_import_ndjson: true)
    end

    context 'when importing a ndjson export' do
      let(:user) { create(:admin) }
      let(:group) { create(:group) }
      let(:service) { described_class.new(group: group, user: user) }
      let(:import_file) { fixture_file_upload('spec/fixtures/group_export.tar.gz') }

      let(:import_logger) { instance_double(Gitlab::Import::Logger) }

      subject { service.execute }

      before do
        ImportExportUpload.create(group: group, import_file: import_file)

        allow(Gitlab::Import::Logger).to receive(:build).and_return(import_logger)
        allow(import_logger).to receive(:error)
        allow(import_logger).to receive(:info)
      end

      context 'when user has correct permissions' do
        it 'imports group structure successfully' do
          expect(subject).to be_truthy
        end

        it 'removes import file' do
          subject

          expect(group.import_export_upload.import_file.file).to be_nil
        end

        it 'logs the import success' do
          expect(import_logger).to receive(:info).with(
            group_id:   group.id,
            group_name: group.name,
            message:    'Group Import/Export: Import succeeded'
          ).once

          subject
        end
      end

      context 'when user does not have correct permissions' do
        let(:user) { create(:user) }

        it 'logs the error and raises an exception' do
          expect(import_logger).to receive(:error).with(
            group_id:   group.id,
            group_name: group.name,
            message:    a_string_including('Errors occurred')
          )

          expect { subject }.to raise_error(Gitlab::ImportExport::Error)
        end

        it 'tracks the error' do
          shared = Gitlab::ImportExport::Shared.new(group)
          allow(Gitlab::ImportExport::Shared).to receive(:new).and_return(shared)

          expect(shared).to receive(:error) do |param|
            expect(param.message).to include 'does not have required permissions for'
          end

          expect { subject }.to raise_error(Gitlab::ImportExport::Error)
        end
      end

      context 'when there are errors with the import file' do
        let(:import_file) { fixture_file_upload('spec/fixtures/symlink_export.tar.gz') }

        it 'logs the error and raises an exception' do
          expect(import_logger).to receive(:error).with(
            group_id:   group.id,
            group_name: group.name,
            message:    a_string_including('Errors occurred')
          ).once

          expect { subject }.to raise_error(Gitlab::ImportExport::Error)
        end
      end

      context 'when there are errors with the sub-relations' do
        let(:import_file) { fixture_file_upload('spec/fixtures/group_export_invalid_subrelations.tar.gz') }

        it 'successfully imports the group' do
          expect(subject).to be_truthy
        end

        it 'logs the import success' do
          allow(Gitlab::Import::Logger).to receive(:build).and_return(import_logger)

          expect(import_logger).to receive(:info).with(
            group_id: group.id,
            group_name: group.name,
            message: 'Group Import/Export: Import succeeded'
          )

          subject
        end
      end
    end

    context 'when importing a json export' do
      let(:user) { create(:admin) }
      let(:group) { create(:group) }
      let(:service) { described_class.new(group: group, user: user) }
      let(:import_file) { fixture_file_upload('spec/fixtures/legacy_group_export.tar.gz') }

      let(:import_logger) { instance_double(Gitlab::Import::Logger) }

      subject { service.execute }

      before do
        ImportExportUpload.create(group: group, import_file: import_file)

        allow(Gitlab::Import::Logger).to receive(:build).and_return(import_logger)
        allow(import_logger).to receive(:error)
        allow(import_logger).to receive(:info)
      end

      context 'when user has correct permissions' do
        it 'imports group structure successfully' do
          expect(subject).to be_truthy
        end

        it 'removes import file' do
          subject

          expect(group.import_export_upload.import_file.file).to be_nil
        end

        it 'logs the import success' do
          expect(import_logger).to receive(:info).with(
            group_id:   group.id,
            group_name: group.name,
            message:    'Group Import/Export: Import succeeded'
          ).once

          subject
        end
      end

      context 'when user does not have correct permissions' do
        let(:user) { create(:user) }

        it 'logs the error and raises an exception' do
          expect(import_logger).to receive(:error).with(
            group_id:   group.id,
            group_name: group.name,
            message:    a_string_including('Errors occurred')
          )

          expect { subject }.to raise_error(Gitlab::ImportExport::Error)
        end

        it 'tracks the error' do
          shared = Gitlab::ImportExport::Shared.new(group)
          allow(Gitlab::ImportExport::Shared).to receive(:new).and_return(shared)

          expect(shared).to receive(:error) do |param|
            expect(param.message).to include 'does not have required permissions for'
          end

          expect { subject }.to raise_error(Gitlab::ImportExport::Error)
        end
      end

      context 'when there are errors with the import file' do
        let(:import_file) { fixture_file_upload('spec/fixtures/legacy_symlink_export.tar.gz') }

        it 'logs the error and raises an exception' do
          expect(import_logger).to receive(:error).with(
            group_id:   group.id,
            group_name: group.name,
            message:    a_string_including('Errors occurred')
          ).once

          expect { subject }.to raise_error(Gitlab::ImportExport::Error)
        end
      end

      context 'when there are errors with the sub-relations' do
        let(:import_file) { fixture_file_upload('spec/fixtures/legacy_group_export_invalid_subrelations.tar.gz') }

        it 'successfully imports the group' do
          expect(subject).to be_truthy
        end

        it 'logs the import success' do
          allow(Gitlab::Import::Logger).to receive(:build).and_return(import_logger)

          expect(import_logger).to receive(:info).with(
            group_id:   group.id,
            group_name: group.name,
            message:    'Group Import/Export: Import succeeded'
          )

          subject
        end
      end
    end
  end
end
