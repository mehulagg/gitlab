# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Mutations::Projects::SetLocked do
  let_it_be(:user) { create(:user) }
  let_it_be(:project) { create(:project) }

  subject(:mutation) { described_class.new(object: nil, context: { current_user: user }, field: nil) }

  describe '#resolve' do
    subject { mutation.resolve(project_path: project.full_path, file_path: file_path, locked: locked) }

    let(:file_path) { 'README.md' }
    let(:locked) { true }
    let(:mutated_path_locks) { subject[:project].path_locks }

    it 'raises an error if the resource is not accessible to the user' do
      expect { subject }.to raise_error(Gitlab::Graphql::Errors::ResourceNotAvailable)
    end

    context 'when the user can lock the file' do
      let(:locked) { true }

      before do
        project.add_developer(user)
      end

      context 'when file is not locked' do
        it 'sets path locks for the project' do
          expect { subject }.to change { project.path_locks.count }.by(1)
          expect(mutated_path_locks.first).to have_attributes(path: file_path, user: user)
        end
      end

      context 'when file is already locked' do
        before do
          create(:path_lock, project: project, path: file_path)
        end

        it 'does not change the lock' do
          expect { subject }.not_to change { project.path_locks.count }
        end
      end
    end

    context 'when the user can unlock the file' do
      let(:locked) { false }

      before do
        project.add_developer(user)
      end

      context 'when file is already locked by the same user' do
        before do
          create(:path_lock, project: project, path: file_path, user: user)
        end

        it 'unlocks the file' do
          expect { subject }.to change { project.path_locks.count }.by(-1)
          expect(mutated_path_locks).to be_empty
        end
      end

      context 'when file is already locked by somebody else' do
        before do
          create(:path_lock, project: project, path: file_path)
        end

        it 'returns an error' do
          expect { subject }.to raise_error(PathLocks::UnlockService::AccessDenied)
        end
      end

      context 'when file is not locked' do
        it 'does nothing' do
          expect { subject }.to change { project.path_locks.count }.by(0)
          expect(mutated_path_locks).to be_empty
        end
      end
    end
  end
end
