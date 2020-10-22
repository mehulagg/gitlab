# frozen_string_literal: true

require 'spec_helper'

RSpec.describe ProjectImportScheduleWorker do
  describe '#perform' do
    it 'does nothing if the database is read-only' do
      project = create(:project)

      allow(Gitlab::Database).to receive(:read_only?).and_return(true)
      expect(ProjectImportState).not_to receive(:project_id).with(project_id: project.id)

      subject.perform(project.id)
    end

    it 'schedules an import for a project' do
      import_state = create(:import_state)

      allow_next_instance_of(EE::Project) do |instance|
        allow(instance).to receive(:add_import_job).and_return(nil)
      end

      expect do
        subject.perform(import_state.project_id)
      end.to change { import_state.reload.status }.from("none").to("scheduled")
    end

    context 'when project is not found' do
      it 'raises ImportStateNotFound' do
        expect { subject.perform(-1) }.to raise_error(described_class::ImportStateNotFound)
      end
    end

    context 'when project does not have import state' do
      it 'raises ImportStateNotFound' do
        project = create(:project)

        expect { subject.perform(project.id) }.to raise_error(described_class::ImportStateNotFound)
      end
    end
  end
end
