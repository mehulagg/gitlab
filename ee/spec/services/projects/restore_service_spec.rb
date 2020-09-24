# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Projects::RestoreService do
  let(:user) { create(:user) }
  let(:pending_delete) { nil }
  let(:project) do
    create(:project,
      :repository,
      namespace: user.namespace,
      marked_for_deletion_at: 1.day.ago,
      deleting_user: user,
      archived: true,
      pending_delete: pending_delete)
  end

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
    let(:pending_delete) { true }

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
