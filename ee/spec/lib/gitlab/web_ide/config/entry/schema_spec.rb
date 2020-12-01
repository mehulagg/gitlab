# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Gitlab::WebIde::Config::Entry::Schema do
  let(:schema) { described_class.new(hash) }

  describe '.nodes' do
    it 'returns a hash' do
      expect(described_class.nodes).to be_a(Hash)
    end

    context 'when filtering all the entry/node names' do
      it 'contains the expected node names' do
        expect(described_class.nodes.keys)
          .to match_array(%i[uri match])
      end
    end
  end

  context 'when configuration is valid' do
    context 'when some entries defined' do
      let(:hash) do
        { uri: 'https://someurl.com', match: ['*.gitlab-ci.yml'] }
      end

      describe '#compose!' do
        before do
          schema.compose!
        end

        it 'creates node object for each entry' do
          expect(schema.descendants.count).to eq 2
        end

        it 'creates node object using valid class' do
          expect(schema.descendants.first)
            .to be_an_instance_of Gitlab::WebIde::Config::Entry::Schema::Uri

          expect(schema.descendants.second)
            .to be_an_instance_of Gitlab::WebIde::Config::Entry::Schema::Match
        end

        it 'sets correct description for nodes' do
          expect(schema.descendants.first.description)
            .to eq 'The URI of the schema.'

          expect(schema.descendants.second.description)
            .to eq 'A list of glob expressions to match against the target file.'
        end

        describe '#leaf?' do
          it 'is not leaf' do
            expect(schema).not_to be_leaf
          end
        end
      end

      context 'when composed' do
        before do
          schema.compose!
        end

        describe '#errors' do
          it 'has no errors' do
            expect(schema.errors).to be_empty
          end
        end

        describe '#uri_value' do
          it 'returns correct uri' do
            expect(schema.uri_value).to eq('https://someurl.com')
          end
        end

        describe '#match_value' do
          it 'returns correct value for schemas' do
            expect(schema.match_value).to eq(['*.gitlab-ci.yml'])
          end
        end
      end
    end
  end

  context 'when configuration is not valid' do
    before do
      schema.compose!
    end

    context 'when the config does not have all the required entries' do
      let(:hash) do
        {}
      end

      describe '#errors' do
        it 'reports errors about the invalid entries' do
          expect(schema.errors)
            .to eq [
              "uri config can't be blank",
              "match config can't be blank"
            ]
        end
      end
    end

    context 'when the config has invalid entries' do
      let(:hash) do
        { uri: 1, match: [2] }
      end

      describe '#errors' do
        it 'reports errors about the invalid entries' do
          expect(schema.errors)
            .to eq [
              "uri config should be a string",
              "match config should be an array of strings"
            ]
        end
      end
    end
  end

  context 'when value is not a hash' do
    let(:hash) { [] }

    describe '#valid?' do
      it 'is not valid' do
        expect(schema).not_to be_valid
      end
    end

    describe '#errors' do
      it 'returns error about invalid type' do
        expect(schema.errors.first).to match /should be a hash/
      end
    end
  end

  describe '#specified?' do
    it 'is concrete entry that is defined' do
      expect(schema.specified?).to be true
    end
  end
end
