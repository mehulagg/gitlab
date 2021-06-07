# frozen_string_literal: true

require 'spec_helper'

module Gitlab
  module Ci
    class Config
      module Entry
        ##
        # Entry that represents a secret definition.
        #
        class DastConfiguration < ::Gitlab::Config::Entry::Node
          include ::Gitlab::Config::Entry::Configurable
          include ::Gitlab::Config::Entry::Attributable

          ALLOWED_KEYS = %i[vault].freeze

          attributes ALLOWED_KEYS

          entry :vault, Entry::Vault::Secret, description: 'Vault secrets engine configuration'

          validations do
            validates :config, allowed_keys: ALLOWED_KEYS, required_keys: ALLOWED_KEYS
          end
        end
      end
    end
  end
end

RSpec.describe Gitlab::Ci::Config::Entry::DastConfiguration do
  let(:entry) { described_class.new(config) }

  describe 'validation' do
    before do
      entry.compose!
    end

    context 'when entry config value is correct' do
      let(:config) do
        {
          vault: {
            engine: { name: 'kv-v2', path: 'kv-v2' },
            path: 'production/db',
            field: 'password'
          }
        }
      end

      describe '#value' do
        it 'returns dast configuration' do
          expect(entry.value).to eq(config)
        end
      end

      describe '#valid?' do
        it 'is valid' do
          expect(entry).to be_valid
        end
      end
    end
  end

  context 'when entry value is not correct' do
    describe '#errors' do
      context 'when there is an unknown key present' do
        let(:config) { { foo: {} } }

        it 'reports error' do
          expect(entry.errors)
            .to include 'dast configuration config contains unknown keys: foo'
        end
      end

      context 'when there is no vault entry' do
        let(:config) { {} }

        it 'reports error' do
          expect(entry.errors)
            .to include 'dast configuration config missing required keys: vault'
        end
      end
    end
  end
end
