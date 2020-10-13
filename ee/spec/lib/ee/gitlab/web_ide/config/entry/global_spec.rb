# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Gitlab::WebIde::Config::Entry::Global do
  let(:global) { described_class.new(hash) }

  describe '.nodes' do
    context 'when filtering all the entry/node names' do
      it 'contains the expected node names' do
        expect(described_class.nodes.keys).to match_array(%i[terminal schemas])
      end
    end
  end

  context 'when configuration is valid' do
    context 'when some entries defined' do
      let(:hash) do
        {
          terminal: { before_script: ['ls'], variables: {}, script: 'sleep 10s', services: ['mysql'] },
          schemas: [{ uri: 'https://someurl.com', match: ['*.gitlab-ci.yml'] }]
        }
      end

      describe '#compose!' do
        before do
          global.compose!
        end

        it 'creates nodes hash' do
          expect(global.descendants).to be_an Array
        end

        it 'creates node object for each entry' do
          expect(global.descendants.count).to eq 2
        end

        it 'creates node object using valid class' do
          expect(global.descendants.first)
            .to be_an_instance_of Gitlab::WebIde::Config::Entry::Terminal
          expect(global.descendants.second)
            .to be_an_instance_of Gitlab::WebIde::Config::Entry::Schemas
        end

        it 'sets correct description for nodes' do
          expect(global.descendants.first.description)
            .to eq 'Configuration of the webide terminal.'
          expect(global.descendants.second.description)
            .to eq 'Configuration of JSON/YAML schemas.'
        end
      end

      context 'when not composed' do
        describe '#schemas_value' do
          it 'returns nil' do
            expect(global.schemas_value).to be nil
          end
        end
      end

      context 'when composed' do
        before do
          global.compose!
        end

        describe '#errors' do
          it 'has no errors' do
            expect(global.errors).to be_empty
          end
        end

        describe '#schemas_value' do
          it 'returns correct value for schemas' do
            expect(global.schemas_value).to eq([{ uri: 'https://someurl.com', match: ['*.gitlab-ci.yml'] }])
          end
        end
      end
    end
  end
end
