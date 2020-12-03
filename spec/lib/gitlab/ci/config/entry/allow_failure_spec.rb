# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Gitlab::Ci::Config::Entry::AllowFailure do
  let(:entry) { described_class.new(config.deep_dup) }
  let(:expected_config) { config }

  describe 'validations' do
    context 'when entry config value is valid' do
      shared_examples 'valid entry' do
        describe '#value' do
          it 'returns key value' do
            expect(entry.value).to eq(expected_config)
          end
        end

        describe '#valid?' do
          it 'is valid' do
            expect(entry).to be_valid
          end
        end
      end

      context 'with boolean values' do
        it_behaves_like 'valid entry' do
          let(:config) { true }
        end

        it_behaves_like 'valid entry' do
          let(:config) { false }
        end
      end

      context 'with hash values' do
        it_behaves_like 'valid entry' do
          let(:config) { { exit_codes: 137 } }
          let(:expected_config) { { exit_codes: [137] } }
        end

        it_behaves_like 'valid entry' do
          let(:config) { { exit_codes: [42, 137] } }
        end
      end
    end

    context 'when entry value is not valid' do
      context 'when it has a wrong type' do
        let(:config) { [1] }

        describe '#valid?' do
          it 'is valid' do
            expect(entry).not_to be_valid
          end
        end

        describe '#errors' do
          it 'saves errors' do
            expect(entry.errors)
              .to include 'allow failure config should be a hash or a boolean value'
          end
        end
      end

      context 'with string exit codes' do
        let(:config) { { exit_codes: 'string' } }

        describe '#valid?' do
          it 'is valid' do
            expect(entry).not_to be_valid
          end
        end

        describe '#errors' do
          it 'saves errors' do
            expect(entry.errors)
              .to include 'allow failure exit codes should be an array of integers or an integer'
          end
        end
      end

      context 'with array of strings as exit codes' do
        let(:config) { { exit_codes: ['string 1', 'string 2'] } }

        describe '#valid?' do
          it 'is valid' do
            expect(entry).not_to be_valid
          end
        end

        describe '#errors' do
          it 'saves errors' do
            expect(entry.errors)
              .to include 'allow failure exit codes should be an array of integers or an integer'
          end
        end
      end

      context 'when it has an extra keys' do
        let(:config) { { extra: true } }

        describe '#valid?' do
          it 'is valid' do
            expect(entry).not_to be_valid
          end
        end

        describe '#errors' do
          it 'saves errors' do
            expect(entry.errors)
              .to include 'allow failure config contains unknown keys: extra'
          end
        end
      end
    end
  end
end
