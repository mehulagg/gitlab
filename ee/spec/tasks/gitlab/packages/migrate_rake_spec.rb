require 'rake_helper'

describe 'gitlab:packages namespace rake task' do
  before :all do
    Rake.application.rake_require 'tasks/gitlab/packages/migrate'
  end

  describe 'migrate' do
    let(:local) { ObjectStorage::Store::LOCAL }
    let(:remote) { ObjectStorage::Store::REMOTE }
    let!(:package_file) { create(:package_file, :pom, file_store: local) }

    def packages_migrate
      run_rake_task('gitlab:packages:migrate')
    end

    context 'object storage disabled' do
      before do
        stub_packages_object_storage(enabled: false)
      end

      it "doesn't migrate files" do
        expect { packages_migrate }.to raise_error('Object store is disabled for packages feature')
      end
    end

    context 'object storage enabled' do
      before do
        stub_packages_object_storage
      end

      it 'migrates local file to object storage' do
        expect { packages_migrate }.to change { package_file.reload.file_store }.from(local).to(remote)
      end
    end
  end

  def stub_packages_object_storage(**params)
    stub_object_storage_uploader(config: Gitlab.config.packages.object_store,
                                 uploader: ::Packages::PackageFileUploader,
                                 remote_directory: 'packages',
                                 **params)
  end
end
