# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Gitlab::Ci::Config::Entry::Job do
  let(:entry) { described_class.new(config, name: :rspec) }

  describe 'validations' do
    context 'when entry value is correct' do
      context 'when has secrets' do
        let(:config) { { script: 'echo', secrets: { DATABASE_PASSWORD: { vault: 'production/db/password' } } } }

        before do
          entry.compose!
        end

        it { expect(entry).to be_valid }
      end
    end

    context 'when entry value is not correct' do
      before do
        entry.compose!
      end

      context 'when has needs' do
        context 'when needs is bridge type' do
          let(:config) do
            {
              script: 'echo',
              stage: 'test',
              needs: { pipeline: 'some/project' }
            }
          end

          it 'returns error about invalid needs type' do
            expect(entry).not_to be_valid
            expect(entry.errors).to contain_exactly('needs config uses invalid types: bridge')
          end
        end
      end

      context 'when has invalid secrets' do
        let(:config) { { script: 'echo', secrets: [] } }

        it 'reports error' do
          expect(entry.errors)
            .to include 'secrets config should be a hash'
        end
      end
    end
  end

  describe '.nodes' do
    context 'when filtering all the entry/node names' do
      subject(:nodes) { described_class.nodes }

      it 'has "secrets" node' do
        expect(nodes).to have_key(:secrets)
      end
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

    it 'includes secrets value' do
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
