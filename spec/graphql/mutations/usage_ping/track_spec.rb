# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Mutations::UsagePing::Track do
  subject(:mutation) { described_class.new(object: nil, context: context, field: nil) }

  let_it_be(:user) { create(:user) }
  let_it_be(:context) do
    GraphQL::Query::Context.new(
      query: OpenStruct.new(schema: nil),
      values: { current_user: user },
      object: nil
    )
  end
  let(:event) { 'static_site_editor_commit' }

  describe '#resolve' do
    subject { mutation.resolve(event: event) }

    it 'returns empty errors list' do
      expect(subject[:errors]).to be_empty
    end

    context 'when event is not supported' do
      let(:event) { 'unknown' }

      it { expect(subject[:errors]).to eq(['Unsupported event']) }
    end
  end
end
