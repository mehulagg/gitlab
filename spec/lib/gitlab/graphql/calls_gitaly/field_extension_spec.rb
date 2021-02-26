# frozen_string_literal: true
require 'spec_helper'

RSpec.describe Gitlab::Graphql::CallsGitaly::FieldExtension, :request_store do
  include GraphqlHelpers

  let(:owner) { fresh_object_type }
  let(:field) do
    ::Types::BaseField.new(name: 'value', type: GraphQL::STRING_TYPE, null: true, owner: owner, **field_args)
  end

  def resolve_value
    resolve_field(field, { value: 'foo' }, object_type: owner)
  end

  context 'when the field has a constant complexity' do
    let(:field_args) { { complexity: 100 } }

    it 'does not run the gitaly checks' do
      expect(described_class).not_to receive(:new)

      resolve_value
    end
  end

  context 'when the field declares that it calls gitaly' do
    let(:field_args) { { calls_gitaly: true } }

    it 'does not run the gitaly checks' do
      expect(described_class).not_to receive(:new)

      resolve_value
    end
  end

  context 'when the field does not claim to call gitaly' do
    let(:field_args) { {} }

    context 'when it does not call gitaly' do
      it 'instantiates the gitaly checks, but does not raise' do
        expect(described_class).to receive(:new).and_call_original

        value = resolve_value

        expect(value).to eq 'foo'
      end
    end

    context 'when it calls gitaly' do
      before do
        owner.define_method :value do
          Gitlab::SafeRequestStore['gitaly_call_actual'] = 1
          'fresh-from-the-gitaly-mines!'
        end
      end

      it 'notices, and raises, mentioning the field' do
        expect { resolve_value }.to raise_error(include('Object.value'))
      end
    end
  end
end
