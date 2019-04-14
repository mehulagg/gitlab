# frozen_string_literal: true

require 'spec_helper'

describe Projects::ImportExport::ExportService do
  describe '#execute' do
    let!(:user) { create(:user) }
    let(:project) { create(:project) }
    let(:shared) { project.import_export_shared }
    let(:service) { described_class.new(project, user) }
    let!(:after_export_strategy) { Gitlab::ImportExport::AfterExportStrategies::DownloadNotificationStrategy.new }

    it 'saves the version' do
      expect(Gitlab::ImportExport::VersionSaver).to receive(:new).and_call_original

      service.execute
    end

    it 'saves the avatar' do
      expect(Gitlab::ImportExport::AvatarSaver).to receive(:new).and_call_original

      service.execute
    end

    it 'saves the models' do
      expect(Gitlab::ImportExport::ProjectTreeSaver).to receive(:new).and_call_original

      service.execute
    end

    it 'saves the uploads' do
      expect(Gitlab::ImportExport::UploadsSaver).to receive(:new).and_call_original

      service.execute
    end

    it 'saves the repo' do
      # once for the normal repo, once for the wiki
      expect(Gitlab::ImportExport::RepoSaver).to receive(:new).twice.and_call_original

      service.execute
    end

    it 'saves the lfs objects' do
      expect(Gitlab::ImportExport::LfsSaver).to receive(:new).and_call_original

      service.execute
    end

    it 'saves the wiki repo' do
      expect(Gitlab::ImportExport::WikiRepoSaver).to receive(:new).and_call_original

      service.execute
    end

    context 'when all saver services succeed' do
      before do
        allow(service).to receive(:save_services).and_return(true)
      end

      it 'saves the project in the file system' do
        expect(Gitlab::ImportExport::Saver).to receive(:save).with(project: project, shared: shared)

        service.execute
      end

      it 'calls the after export strategy' do
        expect(after_export_strategy).to receive(:execute)

        service.execute(after_export_strategy)
      end

      context 'when after export strategy fails' do
        before do
          allow(after_export_strategy).to receive(:execute).and_return(false)
        end

        after do
          service.execute(after_export_strategy)
        end

        it 'removes the remaining exported data' do
          allow(shared).to receive(:export_path).and_return('whatever')
          allow(FileUtils).to receive(:rm_rf)

          expect(FileUtils).to receive(:rm_rf).with(shared.export_path)
        end

        it 'notifies the user' do
          expect_any_instance_of(NotificationService).to receive(:project_not_exported)
        end

        it 'notifies logger' do
          allow(Rails.logger).to receive(:error)

          expect(Rails.logger).to receive(:error)
        end
      end
    end

    context 'when saver services fail' do
      before do
        allow(service).to receive(:save_services).and_return(false)
      end

      after do
        expect { service.execute }.to raise_error(Gitlab::ImportExport::Error)
      end

      it 'removes the remaining exported data' do
        allow(shared).to receive(:export_path).and_return('whatever')
        allow(FileUtils).to receive(:rm_rf)

        expect(FileUtils).to receive(:rm_rf).with(shared.export_path)
      end

      it 'notifies the user' do
        expect_any_instance_of(NotificationService).to receive(:project_not_exported)
      end

      it 'notifies logger' do
        expect(Rails.logger).to receive(:error)
      end

      it 'the after export strategy is not called' do
        expect(service).not_to receive(:execute_after_export_action)
      end
    end
  end
end
