# frozen_string_literal: true

require 'spec_helper'

RSpec.describe GitlabSchema.types['JsonString'] do
  let(:hash) do
    {
      one: { key: 'value one' },
      two: 'value two'
    }
  end

  specify { expect(described_class.graphql_name).to eq('JsonString') }

  describe '.coerce_input' do
    subject(:input) { described_class.coerce_isolated_input(json_string) }

    context 'when a JSON string is a valid JSON' do
      let(:json_string) { hash.to_json }

      it 'coerces JSON string into a Hash' do
        expect(input).to eq(Gitlab::Json.parse!(json_string))
      end
    end

    context 'when a JSON string is not a JSON' do
      let(:json_string) { 'not a JSON' }

      it 'raises an exception' do
        expect { input }.to raise_error(GraphQL::CoercionError).with_message(%r{Invalid JSON string})
      end
    end
  end

  describe '.coerce_result' do
    subject(:result) { described_class.coerce_isolated_result(hash) }

    it 'coerces a hash to a JSON string' do
      expect(result).to eq(hash.to_json)
    end
  end
end
