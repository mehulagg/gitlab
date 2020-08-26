# frozen_string_literal: true

require "spec_helper"

RSpec.describe Gitlab::EncryptedConfiguration do
  subject(:configuration) { described_class.new }

  describe '#initialize' do
    it 'accepts all args as optional fields' do
      expect { configuration }.not_to raise_exception

      expect(configuration.key).to be_nil
      expect(configuration.previous_keys).to be_empty
    end
  end

  context 'when provided key and config file' do
    let!(:config_tmp_dir) { Dir.mktmpdir('config-') }
    let(:credentials_config_path) { File.join(config_tmp_dir, 'credentials.yml.enc') }
    let(:credentials_key) { ActiveSupport::EncryptedConfiguration.generate_key }

    after do
      FileUtils.rm_f(config_tmp_dir)
    end

    describe '#write' do
      it 'encrypts the file using the provided key' do
        encryptor = ActiveSupport::MessageEncryptor.new([credentials_key].pack('H*'), cipher: 'aes-128-gcm')
        config = described_class.new(content_path: credentials_config_path, key: credentials_key)

        config.write('sample-content')
        expect(encryptor.decrypt_and_verify(File.read(credentials_config_path))).to eq('sample-content')
      end
    end

    describe '#read' do
      it 'reads yaml configuration' do
        config = described_class.new(content_path: credentials_config_path, key: credentials_key)

        config.write({ foo: { bar: true } }.to_yaml)
        expect(config.foo[:bar]).to be true
      end
    end

    describe '#change' do
      it 'changes yaml configuration' do
        config = described_class.new(content_path: credentials_config_path, key: credentials_key)

        config.write({ foo: { bar: true } }.to_yaml)
        config.change do |unencrypted_file|
          contents = YAML.safe_load(unencrypted_file.read, [Symbol])
          unencrypted_file.write contents.merge(beef: "stew").to_yaml
        end
        expect(config.foo[:bar]).to be true
        expect(config.beef).to eq('stew')
      end
    end
  end
end
