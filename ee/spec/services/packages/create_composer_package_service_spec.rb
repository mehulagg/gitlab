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
    it 'creates a new package with tar archive and json meta files ' do
      params = params_hash.to_json
      package_file = described_class.new(project, current_user, params).execute
      package_params = params_hash['package_file']

      expect(package_params['filename']).to match(package_file['file_name'])
      expect(package_params['length']).to match(package_file['size'])
    end
  end
end
