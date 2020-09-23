# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Resolvers::Clusters::AgentsResolver do
  include GraphqlHelpers

  it { expect(described_class).to be < LooksAhead }

  it { expect(described_class.type).to eq(Types::Clusters::AgentType) }
  it { expect(described_class.null).to be_truthy }

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
