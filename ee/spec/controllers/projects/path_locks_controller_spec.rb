# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Projects::PathLocksController do
  let(:project) { create(:project, :repository, :public) }
  let(:user)    { project.owner }
  let(:file_path) { 'files/lfs/lfs_object.iso' }

  before do
    sign_in(user)

    allow_any_instance_of(Repository).to receive(:root_ref).and_return('lfs')
  end

  describe 'GET #index' do
    it 'displays the lock paths' do
      get :index, params: { namespace_id: project.namespace, project_id: project }

      expect(response).to have_gitlab_http_status(:ok)
    end

    context 'when the user does not have access' do
      let(:project) { create(:project, :repository, :public, :repository_private) }
      let(:user) { create(:user) }

      it 'does not allow access' do
        get :index, params: { namespace_id: project.namespace, project_id: project }

        expect(response).to have_gitlab_http_status(:not_found)
      end
    end
  end

  describe 'POST #toggle' do
    context 'when LFS is enabled' do
      before do
        allow_any_instance_of(Project).to receive(:lfs_enabled?).and_return(true)
      end

      context 'when locking a file' do
        it 'locks the file' do
          toggle_lock(file_path)

          expect(PathLock.count).to eq(1)
          expect(response).to have_gitlab_http_status(:ok)
        end

        it "locks the file in LFS" do
          expect { toggle_lock(file_path) }.to change { LfsFileLock.count }.to(1)
        end

        it "tries to create the PathLock only once" do
          expect(PathLocks::LockService).to receive(:new).once.and_return(double.as_null_object)

          toggle_lock(file_path)
        end
      end

      context 'when locking a directory' do
        it 'locks the directory' do
          expect { toggle_lock('bar/') }.to change { PathLock.count }.to(1)

          expect(response).to have_gitlab_http_status(:ok)
        end

        it 'does not locks the directory through LFS' do
          expect { toggle_lock('bar/') }.not_to change { LfsFileLock.count }

          expect(response).to have_gitlab_http_status(:ok)
        end
      end

      context 'when unlocking a file' do
        context 'with files' do
          before do
            toggle_lock(file_path)
          end

          it 'unlocks the file' do
            expect { toggle_lock(file_path) }.to change { PathLock.count }.to(0)

            expect(response).to have_gitlab_http_status(:ok)
          end

          it "unlocks the file in LFS" do
            expect { toggle_lock(file_path) }.to change { LfsFileLock.count }.to(0)
          end
        end
      end

      context 'when unlocking a directory' do
        before do
          toggle_lock('bar')
        end

        it 'unlocks the directory' do
          expect { toggle_lock('bar') }.to change { PathLock.count }.to(0)

          expect(response).to have_gitlab_http_status(:ok)
        end

        it 'does not call the LFS unlock service' do
          expect(Lfs::UnlockFileService).not_to receive(:new)

          toggle_lock('bar')
        end
      end
    end

    context 'when LFS is not enabled' do
      it 'locks the file' do
        expect { toggle_lock(file_path) }.to change { PathLock.count }.to(1)

        expect(response).to have_gitlab_http_status(:ok)
      end

      it "doesn't lock the file in LFS" do
        expect { toggle_lock(file_path) }.not_to change { LfsFileLock.count }
      end

      it 'unlocks the file' do
        toggle_lock(file_path)

        expect { toggle_lock(file_path) }.to change { PathLock.count }.to(0)

        expect(response).to have_gitlab_http_status(:ok)
      end
    end

    context 'when the user does not have access' do
      let(:project) { create(:project, :repository, :public, :repository_private) }
      let(:user) { create(:user) }

      it 'does not allow access' do
        toggle_lock(file_path)

        expect(response).to have_gitlab_http_status(:not_found)
      end
    end
  end

  def toggle_lock(path)
    post :toggle, params: { namespace_id: project.namespace, project_id: project, path: path }
  end
end
