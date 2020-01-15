# frozen_string_literal: true
require 'spec_helper'

describe Packages::CreateComposerPackageService do
  let(:current_user) { create(:user) }
  let(:project) { create(:project) }

  let(:params_hash) do
    {
      'name' => 'ochorocho/gitlab-composer',
      'version' => '2.0.0',
      'json' => File.read('ee/spec/fixtures/api/schemas/public_api/v4/packages/composer_package_version.json'),
      'shasum' => '',
      'package_file' => {
        'contents' => Base64.encode64(File.read('ee/spec/fixtures/composer/ochorocho-gitlab-composer-2.0.0-19c3ec.tar')),
        'length' => File.size('ee/spec/fixtures/composer/ochorocho-gitlab-composer-2.0.0-19c3ec.tar'),
        'file_sha1' => 'c775f1f5cc34f272e25c17b62e1932d0ca5087f8',
        'filename' => 'ochorocho-gitlab-composer-2.0.0-19c3ec.tar'
      }
    }
  end

  describe '#execute' do
    subject { described_class.new(project, current_user, params_hash.to_json).execute }

    context 'when package is new' do
      it 'creates a new package with tar archive and json meta files ' do
        expect { subject }.to change(Packages::Package, :count).by(1)
          .and change(Packages::PackageFile, :count).by(1)
          .and change(Packages::ComposerMetadatum, :count).by(1)

        package_params = params_hash['package_file']

        expect(package_params['filename']).to match(subject['file_name'])
        expect(package_params['length']).to match(subject['size'])
      end
    end

    context 'with an existing package' do
      before do
        described_class.new(project, current_user, params_hash.to_json).execute
      end

      let(:new_json) { "{ dist: { shasum: 'c775f1f5cc34f272e25c17b62e1932d0ca5087f8' } }" }

      it 'updates the package' do
        params_hash['package_file']['filename'] = 'foobar.tar'
        params_hash['json'] = new_json

        expect { subject }.to change(Packages::Package, :count).by(0)
          .and change(Packages::PackageFile, :count).by(0)
          .and change(Packages::ComposerMetadatum, :count).by(0)

        expect(subject['file_name']).to match('foobar.tar')
        expect(subject.package.composer_metadatum.json).to eq new_json
        expect(subject.package.reload.package_files.size).to eq 1
      end
    end
  end
end
