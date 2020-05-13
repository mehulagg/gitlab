# frozen_string_literal: true

require 'spec_helper'

describe Packages::Nuget::UpdatePackageFromMetadataService, :clean_gitlab_redis_shared_state do
  include ExclusiveLeaseHelpers

  let(:package) { create(:nuget_package) }
  let(:package_file) { package.package_files.first }
  let(:service) { described_class.new(package_file) }
  let(:package_name) { 'DummyProject.DummyPackage' }
  let(:package_version) { '1.0.0' }
  let(:package_file_name) { 'dummyproject.dummypackage.1.0.0.nupkg' }

  describe '#execute' do
    subject { service.execute }

    before do
      stub_package_file_object_storage(enabled: true, direct_upload: true)
    end

    RSpec.shared_examples 'taking the lease' do
      before do
        allow(service).to receive(:lease_release?).and_return(false)
      end

      it 'takes the lease' do
        expect(service).to receive(:try_obtain_lease).and_call_original

        subject

        expect(service.exclusive_lease.exists?).to be_truthy
      end
    end

    RSpec.shared_examples 'not updating the package if the lease is taken' do
      context 'without obtaining the exclusive lease' do
        let(:lease_key) { "packages:nuget:update_package_from_metadata_service:package:#{package_id}" }
        let(:metadata) { { package_name: package_name, package_version: package_version } }
        let(:package_from_package_file) { package_file.package }

        before do
          stub_exclusive_lease_taken(lease_key, timeout: 1.hour)
          # to allow the above stub, we need to stub the metadata function as the
          # original implementation will try to get an exclusive lease on the
          # file in object storage
          allow(service).to receive(:metadata).and_return(metadata)
        end

        it 'does not update the package' do
          expect(service).to receive(:try_obtain_lease).and_call_original

          expect { subject }
            .to change { ::Packages::Package.count }.by(0)
            .and change { Packages::DependencyLink.count }.by(0)
          expect(package_file.reload.file_name).not_to eq(package_file_name)
          expect(package_file.package.reload.name).not_to eq(package_name)
          expect(package_file.package.version).not_to eq(package_version)
        end
      end
    end

    context 'with no existing package' do
      let(:package_id) { package.id }

      it 'updates package and package file' do
        expect { subject }
          .to change { Packages::Dependency.count }.by(1)
          .and change { Packages::DependencyLink.count }.by(1)

        expect(package.reload.name).to eq(package_name)
        expect(package.version).to eq(package_version)
        expect(package_file.reload.file_name).to eq(package_file_name)
        # hard reset needed to properly reload package_file.file
        expect(Packages::PackageFile.find(package_file.id).file.size).not_to eq 0
      end

      it_behaves_like 'taking the lease'

      it_behaves_like 'not updating the package if the lease is taken'
    end

    context 'with existing package' do
      let!(:existing_package) { create(:nuget_package, project: package.project, name: package_name, version: package_version) }
      let(:package_id) { existing_package.id }

      it 'link existing package and updates package file' do
        expect(service).to receive(:try_obtain_lease).and_call_original

        expect { subject }
          .to change { ::Packages::Package.count }.by(-1)
          .and change { Packages::Dependency.count }.by(0)
          .and change { Packages::DependencyLink.count }.by(0)
          .and change { Packages::Nuget::DependencyLinkMetadatum.count }.by(0)
        expect(package_file.reload.file_name).to eq(package_file_name)
        expect(package_file.package).to eq(existing_package)
      end

      it_behaves_like 'taking the lease'

      it_behaves_like 'not updating the package if the lease is taken'
    end

    context 'with a nuspec file with metadata' do
      let(:nuspec_filepath) { 'nuget/with_metadata.nuspec' }
      let(:expected_tags) { %w(foo bar test tag1 tag2 tag3 tag4 tag5) }

      before do
        allow_any_instance_of(Packages::Nuget::MetadataExtractionService)
          .to receive(:nuspec_file)
          .and_return(fixture_file(nuspec_filepath, dir: 'ee'))
      end

      it 'creates tags' do
        expect(service).to receive(:try_obtain_lease).and_call_original
        expect { subject }.to change { ::Packages::Tag.count }.by(8)
        expect(package.reload.tags.map(&:name)).to contain_exactly(*expected_tags)
      end

      context 'with existing package and tags' do
        let!(:existing_package) { create(:nuget_package, project: package.project, name: 'DummyProject.WithMetadata', version: '1.2.3') }
        let!(:tag1) { create(:packages_tag, package: existing_package, name: 'tag1') }
        let!(:tag2) { create(:packages_tag, package: existing_package, name: 'tag2') }
        let!(:tag3) { create(:packages_tag, package: existing_package, name: 'tag_not_in_metadata') }

        it 'creates tags and deletes those not in metadata' do
          expect(service).to receive(:try_obtain_lease).and_call_original
          expect { subject }.to change { ::Packages::Tag.count }.by(5)
          expect(existing_package.tags.map(&:name)).to contain_exactly(*expected_tags)
        end
      end
    end

    context 'with nuspec file with dependencies' do
      let(:nuspec_filepath) { 'nuget/with_dependencies.nuspec' }
      let(:package_name) { 'Test.Package' }
      let(:package_version) { '3.5.2' }
      let(:package_file_name) { 'test.package.3.5.2.nupkg' }

      before do
        allow_any_instance_of(Packages::Nuget::MetadataExtractionService)
          .to receive(:nuspec_file)
          .and_return(fixture_file(nuspec_filepath, dir: 'ee'))
      end

      it 'updates package and package file' do
        expect { subject }
          .to change { ::Packages::Package.count }.by(1)
          .and change { Packages::Dependency.count }.by(4)
          .and change { Packages::DependencyLink.count }.by(4)
          .and change { Packages::Nuget::DependencyLinkMetadatum.count }.by(2)

        expect(package.reload.name).to eq(package_name)
        expect(package.version).to eq(package_version)
        expect(package_file.reload.file_name).to eq(package_file_name)
        # hard reset needed to properly reload package_file.file
        expect(Packages::PackageFile.find(package_file.id).file.size).not_to eq 0
      end
    end

    context 'with package file not containing a nuspec file' do
      before do
        allow_any_instance_of(Zip::File).to receive(:glob).and_return([])
      end

      it 'raises an error' do
        expect { subject }.to raise_error(::Packages::Nuget::MetadataExtractionService::ExtractionError)
      end
    end

    context 'with package file with a blank package name' do
      before do
        allow(service).to receive(:package_name).and_return('')
      end

      it 'raises an error' do
        expect { subject }.to raise_error(::Packages::Nuget::UpdatePackageFromMetadataService::InvalidMetadataError)
      end
    end

    context 'with package file with a blank package version' do
      before do
        allow(service).to receive(:package_version).and_return('')
      end

      it 'raises an error' do
        expect { subject }.to raise_error(::Packages::Nuget::UpdatePackageFromMetadataService::InvalidMetadataError)
      end
    end

    context 'with an invalid package version' do
      invalid_versions = [
        '555',
        '1.2',
        '1./2.3',
        '../../../../../1.2.3',
        '%2e%2e%2f1.2.3'
      ]

      invalid_versions.each do |invalid_version|
        it "raises an error for version #{invalid_version}" do
          allow(service).to receive(:package_version).and_return(invalid_version)

          expect { subject }.to raise_error(ActiveRecord::RecordInvalid, 'Validation failed: Version is invalid')
          expect(package_file.file_name).not_to include(invalid_version)
          expect(package_file.file.file.path).not_to include(invalid_version)
        end
      end
    end
  end
end
