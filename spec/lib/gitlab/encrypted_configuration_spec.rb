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
        expect(config[:foo][:bar]).to be true
      end

      it 'allows referencing top level keys via dot syntax' do
        config = described_class.new(content_path: credentials_config_path, key: credentials_key)

        config.write({ foo: { bar: true } }.to_yaml)
        expect(config.foo[:bar]).to be true
      end
    end

    describe '#change' do
      it 'changes yaml configuration' do
        config = described_class.new(content_path: credentials_config_path, key: credentials_key)

        config.write({ foo: { bar: true } }.to_yaml)
        config.change do |unencrypted_contents|
          contents = YAML.safe_load(unencrypted_contents, permitted_classes: [Symbol])
          contents.merge(beef: "stew").to_yaml
        end
        expect(config.foo[:bar]).to be true
        expect(config.beef).to eq('stew')
      end
    end

    context 'when provided previous_keys for rotation' do
      let!(:config_tmp_dir) { Dir.mktmpdir('config-') }
      let(:credential_key_original) { ActiveSupport::EncryptedConfiguration.generate_key }
      let(:credential_key_latest) { ActiveSupport::EncryptedConfiguration.generate_key }
      let(:config_path_original) { File.join(config_tmp_dir, 'credentials-orig.yml.enc') }
      let(:config_path_latest) { File.join(config_tmp_dir, 'credentials-latest.yml.enc') }

      after do
        FileUtils.rm_f(config_tmp_dir)
      end

      def encryptor(key)
        ActiveSupport::MessageEncryptor.new([key].pack('H*'), cipher: 'aes-128-gcm')
      end

      describe '#write' do
        it 'rotates the key when provided a new key' do
          config1 = described_class.new(content_path: config_path_original, key: credential_key_original)
          config1.write('sample-content1')

          config2 = described_class.new(content_path: config_path_latest, key: credential_key_latest, previous_keys: [credential_key_original])
          config2.write('sample-content2')

          original_key_encryptor = encryptor(credential_key_original) # can read with the initial key
          latest_key_encryptor = encryptor(credential_key_latest) # can read with the new key
          both_key_encryptor = encryptor(credential_key_latest) # can read with either key
          both_key_encryptor.rotate([credential_key_original].pack("H*"))

          expect(original_key_encryptor.decrypt_and_verify(File.read(config_path_original))).to eq('sample-content1')
          expect(both_key_encryptor.decrypt_and_verify(File.read(config_path_original))).to eq('sample-content1')
          expect(latest_key_encryptor.decrypt_and_verify(File.read(config_path_latest))).to eq('sample-content2')
          expect(both_key_encryptor.decrypt_and_verify(File.read(config_path_latest))).to eq('sample-content2')
          expect { original_key_encryptor.decrypt_and_verify(File.read(config_path_latest)) }.to raise_error(ActiveSupport::MessageEncryptor::InvalidMessage)
        end
      end

      describe '#read' do
        it 'supports reading using rotated config' do
          described_class.new(content_path: config_path_original, key: credential_key_original).write({ foo: { bar: true } }.to_yaml)

          config = described_class.new(content_path: config_path_original, key: credential_key_latest,  previous_keys: [credential_key_original])
          expect(config[:foo][:bar]).to be true
        end
      end
    end
  end
end
