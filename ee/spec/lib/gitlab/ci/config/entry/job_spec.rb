# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Gitlab::Ci::Config::Entry::Job do
  let(:entry) { described_class.new(config, name: :rspec) }

  describe '.nodes' do
    context 'when filtering all the entry/node names' do
      subject { described_class.nodes.keys }

      let(:result) { %i[dast_configuration secrets] }

      it { is_expected.to include(*result) }
    end
  end

  describe 'validations' do
    shared_examples_for 'a valid entry' do
      before do
        entry.compose!
      end

      describe '#valid?' do
        it 'is valid' do
          expect(entry).to be_valid
        end
      end
    end

    shared_examples_for 'an invalid entry' do |message|
      before do
        entry.compose!
      end

      it 'reports error', :aggregate_failures do
        expect(entry).not_to be_valid
        expect(entry.errors).to contain_exactly(message)
      end
    end

    context 'when entry value is correct' do
      context 'when has secrets' do
        let(:config) { { script: 'echo', secrets: { DATABASE_PASSWORD: { vault: 'production/db/password' } } } }

        it_behaves_like 'a valid entry'
      end

      context 'when has dast_configuration' do
        let(:config) { { script: 'echo', dast_configuration: { site_profile: 'Site profile', scanner_profile: 'Scanner profile' } } }

        it_behaves_like 'a valid entry'
      end
    end

    context 'when entry value is not correct' do
      context 'when has needs' do
        context 'when needs is bridge type' do
          let(:config) { { script: 'echo', stage: 'test', needs: { pipeline: 'some/project' } } }

          it_behaves_like 'an invalid entry', 'needs config uses invalid types: bridge'
        end
      end

      context 'when has invalid dast_configuration' do
        let(:config) { { script: 'echo', dast_configuration: [] } }

        it_behaves_like 'an invalid entry', 'dast_configuration config should be a hash'
      end

      context 'when has invalid secrets' do
        let(:config) { { script: 'echo', secrets: [] } }

        it_behaves_like 'an invalid entry', 'secrets config should be a hash'
      end
    end
  end

  describe 'dast_configuration' do
    let(:config) { { script: 'echo', dast_configuration: { site_profile: 'Site profile', scanner_profile: 'Scanner profile' } } }

    before do
      entry.compose!
    end

    it 'includes dast_profile value', :aggregate_failures do
      expect(entry.errors).to be_empty
      expect(entry.value[:dast_configuration]).to eq(config[:dast_configuration])
    end
  end

  describe 'secrets' do
    let(:config) { { script: 'echo', secrets: secrets } }
    let(:secrets) do
      {
        DATABASE_PASSWORD: { vault: 'production/db/password' },
        SSL_PRIVATE_KEY: { vault: 'production/ssl/private-key@ops' },
        S3_SECRET_KEY: {
          vault: {
            engine: { name: 'kv-v2', path: 'aws' },
            path: 'production/s3',
            field: 'secret-key'
          }
        }
      }
    end

    before do
      entry.compose!
    end

    it 'includes secrets value', :aggregate_failures do
      expect(entry.errors).to be_empty
      expect(entry.value[:secrets]).to eq({
        DATABASE_PASSWORD: {
          vault: {
            engine: { name: 'kv-v2', path: 'kv-v2' },
            path: 'production/db',
            field: 'password'
          }
        },
        SSL_PRIVATE_KEY: {
          vault: {
            engine: { name: 'kv-v2', path: 'ops' },
            path: 'production/ssl',
            field: 'private-key'
          }
        },
        S3_SECRET_KEY: {
          vault: {
            engine: { name: 'kv-v2', path: 'aws' },
            path: 'production/s3',
            field: 'secret-key'
          }
        }
      })
    end
  end
end
