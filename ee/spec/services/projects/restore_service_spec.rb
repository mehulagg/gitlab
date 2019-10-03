# frozen_string_literal: true

require 'spec_helper'

describe Projects::RestoreService do
  let(:user) { create(:user) }
  let(:project) { create(:project, :repository, namespace: user.namespace) }

  context 'restoring project' do
    before do
      described_class.new(project, user).execute
    end

    it 'marks project as unarchived and not marked for deletion' do
      expect(Project.unscoped.all).to include(project)

      expect(project.archived).to eq(false)
      expect(project.marked_for_deletion_at).to be_nil
      expect(project.deleting_user).to eq(nil)
    end
  end

  context 'restoring project already in process of removal' do
    let(:deletion_date) { 2.days.ago }

    before do
      project.update(pending_delete: true)
    end

    it 'does not allow to restore' do
      expect(described_class.new(project, user).execute).to include(status: :error)
    end
  end

  context 'audit events' do
    it 'saves audit event' do
      expect { described_class.new(project, user).execute }
        .to change { AuditEvent.count }.by(1)
    end
  end
end
