# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Terraform::StateUploader do
  subject { terraform_state_version.file }

  let(:terraform_state_version) { create(:terraform_state_version) }

  before do
    stub_terraform_state_object_storage
  end

  describe '#filename' do
    it 'contains the version of the terraform state version record' do
      expect(subject.filename).to eq("#{terraform_state_version.version}.tfstate")
    end
  end

  describe '#store_dir' do
    it 'hashes the project ID and UUID' do
      expect(Gitlab::HashedPath).to receive(:new)
        .with(terraform_state_version.uuid, root_hash: terraform_state_version.project_id)
        .and_return(:store_dir)

      expect(subject.store_dir).to eq(:store_dir)
    end
  end

  describe '#key' do
    it 'creates a digest with a secret key and the project id' do
      expect(OpenSSL::HMAC)
        .to receive(:digest)
        .with('SHA256', Gitlab::Application.secrets.db_key_base, terraform_state_version.project_id.to_s)
        .and_return('digest')

      expect(subject.key).to eq('digest')
    end
  end

  describe 'encryption' do
    it 'encrypts the stored file' do
      expect(subject.file.read).not_to eq(fixture_file('terraform/terraform.tfstate'))
    end

    it 'decrypts the file when reading' do
      expect(subject.read).to eq(fixture_file('terraform/terraform.tfstate'))
    end
  end

  describe '.direct_upload_enabled?' do
    it 'returns false' do
      expect(described_class.direct_upload_enabled?).to eq(false)
    end
  end

  describe '.background_upload_enabled?' do
    it 'returns false' do
      expect(described_class.background_upload_enabled?).to eq(false)
    end
  end

  describe '.proxy_download_enabled?' do
    it 'returns true' do
      expect(described_class.proxy_download_enabled?).to eq(true)
    end
  end

  describe '.default_store' do
    context 'when object storage is enabled' do
      it 'returns REMOTE' do
        expect(described_class.default_store).to eq(ObjectStorage::Store::REMOTE)
      end
    end

    context 'when object storage is disabled' do
      before do
        stub_terraform_state_object_storage(enabled: false)
      end

      it 'returns LOCAL' do
        expect(described_class.default_store).to eq(ObjectStorage::Store::LOCAL)
      end
    end
  end
end
