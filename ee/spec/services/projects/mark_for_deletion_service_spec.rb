# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Projects::MarkForDeletionService do
  let(:user) { create(:user) }
  let(:marked_for_deletion_at) { nil }
  let(:project) do
    create(:project,
      :repository,
      namespace: user.namespace,
      marked_for_deletion_at: marked_for_deletion_at)
  end

  context 'with delayed delete feature turned on' do
    before do
      stub_licensed_features(adjourned_deletion_for_projects_and_groups: true)
    end

    context 'marking project for deletion' do
      it 'marks project as archived and marked for deletion' do
        result = described_class.new(project, user).execute

        expect(result[:status]).to eq(:success)
        expect(Project.unscoped.all).to include(project)
        expect(project.archived).to eq(true)
        expect(project.marked_for_deletion_at).not_to be_nil
        expect(project.deleting_user).to eq(user)
      end
    end

    context 'marking project for deletion once again' do
      let(:marked_for_deletion_at) { 2.days.ago }

      it 'does not change original date' do
        result = described_class.new(project, user).execute

        expect(result[:status]).to eq(:success)
        expect(project.marked_for_deletion_at).to eq(marked_for_deletion_at.to_date)
      end
    end

    context 'audit events' do
      it 'saves audit event' do
        expect { described_class.new(project, user).execute }
          .to change { AuditEvent.count }.by(1)
      end
    end
  end

  context 'with delayed delete feature turned off' do
    context 'marking project for deletion' do
      before do
        described_class.new(project, user).execute
      end

      it 'does not change project attributes' do
        result = described_class.new(project, user).execute

        expect(result[:status]).to eq(:error)
        expect(Project.all).to include(project)

        expect(project.archived).to eq(false)
        expect(project.marked_for_deletion_at).to be_nil
        expect(project.deleting_user).to be_nil
      end
    end
  end
end
