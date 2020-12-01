# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Resolvers::Clusters::AgentsResolver do
  include GraphqlHelpers

  specify do
    expect(described_class).to have_nullable_graphql_type(Types::Clusters::AgentType.connection_type)
  end

  specify do
    expect(described_class.field_options).to include(extras: include(:lookahead))
  end

  describe '#resolve' do
    let_it_be(:user) { create(:user) }

    let(:finder) { double(execute: relation) }
    let(:relation) { double }
    let(:project) { create(:project) }
    let(:args) { Hash(key: 'value') }
    let(:ctx) { Hash(current_user: user) }

    let(:lookahead) do
      double(selects?: true).tap do |selection|
        allow(selection).to receive(:selection).and_return(selection)
      end
    end

    subject { resolve(described_class, obj: project, args: args.merge(lookahead: lookahead), ctx: ctx) }

    it 'calls the agents finder' do
      expect(::Clusters::AgentsFinder).to receive(:new)
        .with(project, user, params: args).and_return(finder)

      expect(relation).to receive(:preload)
        .with(:agent_tokens).and_return(relation)

      expect(subject).to eq(relation)
    end
  end
end

RSpec.describe Resolvers::Clusters::AgentsResolver.single do
  it { expect(described_class).to be < Resolvers::Clusters::AgentsResolver }

  describe '.field_options' do
    subject { described_class.field_options }

    specify do
      expect(subject).to include(
        type: ::Types::Clusters::AgentType,
        null: true,
        extras: [:lookahead]
      )
    end
  end

  describe 'arguments' do
    subject { described_class.arguments[argument] }

    describe 'name' do
      let(:argument) { 'name' }

      it do
        expect(subject).to be_present
        expect(subject.type.to_s).to eq('String!')
        expect(subject.description).to be_present
      end
    end
  end
end
